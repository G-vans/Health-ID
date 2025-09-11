# app/services/health_reasoning_service.rb
require 'ollama-ai'

class HealthReasoningService
  attr_reader :client, :patient

  def initialize(patient)
    @patient = patient
    @client = Ollama.new(
      credentials: { address: 'http://localhost:11434' },
      options: { server_sent_events: true }
    )
  end

  def analyze_new_lab_results(lab_result)
    historical_data = patient.lab_results.order(created_at: :desc).limit(5)
    
    prompt = build_analysis_prompt(lab_result, historical_data)
    
    response = client.generate(
      { 
        model: 'gpt-oss:20b',
        prompt: prompt,
        stream: false
      }
    )
    
    analysis = parse_reasoning_output(response)
    
    if should_send_alert?(analysis)
      HealthAlertJob.perform_later(patient, analysis)
    end
    
    store_analysis(lab_result, analysis)
    
    analysis
  end
  

  def generate_travel_advisory(destination, departure_date)
    health_profile = build_health_profile
    destination_data = fetch_destination_health_data(destination)
    
    prompt = """
    Generate a personalized travel health advisory for a patient traveling to #{destination}.
    
    PATIENT HEALTH PROFILE:
    #{health_profile.to_json}
    
    DESTINATION: #{destination}
    Climate: #{destination_data[:climate]}
    Common Diseases: #{destination_data[:diseases]}
    Healthcare Quality: #{destination_data[:healthcare_quality]}
    Departure Date: #{departure_date}
    
    Please provide:
    1. HEALTH_RISKS: Specific risks based on patient's conditions and destination
    2. MEDICATION_ADJUSTMENTS: Changes needed for climate/altitude
    3. VACCINATIONS: Required or recommended vaccines
    4. PRECAUTIONS: Specific precautions for this patient
    5. EMERGENCY_PREP: What to prepare for emergencies
    6. LOCAL_HOSPITALS: Recommended facilities
    
    Consider interactions between patient's conditions and destination factors.
    Focus on actionable, specific recommendations.
    """
    
    response = client.generate(
      { 
        model: 'gpt-oss:20b',
        prompt: prompt,
        stream: false
      }
    )
    
    advisory = parse_travel_advisory(response)
    
    # Create travel advisory record
    patient.travel_advisories.create!(
      destination: destination,
      departure_date: departure_date,
      health_risks: advisory[:health_risks],
      preparations: advisory[:preparations],
      emergency_contacts: advisory[:emergency_contacts]
    )
    
    advisory
  end

  def detect_anomalies
    recent_results = patient.lab_results.includes(:lab).order(test_date: :desc).limit(10)
    anomalies = []
    
    recent_results.each do |result|
      if critical_value?(result.test_name, result.result_value)
        anomalies << {
          type: 'CRITICAL_VALUE',
          test: result.test_name,
          value: result.result_value,
          date: result.test_date,
          location: result.lab.name
        }
      end
    end
    
    # Check for concerning trends
    trends = analyze_trends(recent_results)
    anomalies.concat(trends[:concerning]) if trends[:concerning].any?
    
    anomalies
  end

  def compare_results_over_time
    historical = patient.lab_results.order(created_at: :desc).limit(5)
    
    return { message: "Insufficient data for comparison" } if historical.count < 2
    
    prompt = """
    Analyze these lab results over time and identify trends:
    
    #{historical.map { |r| format_lab_result(r) }.join("\n\n")}
    
    Provide:
    1. TREND_ANALYSIS: Identify improving, worsening, or stable trends
    2. RISK_PROJECTION: Project future health risks based on trends
    3. INTERVENTION_TIMING: Suggest when interventions are needed
    4. SUCCESS_METRICS: Define what improvement looks like
    """
    
    response = client.generate(
      { 
        model: 'gpt-oss:20b',
        prompt: prompt,
        stream: false
      }
    )
    
    parse_trend_analysis(response)
  end

  private

  def build_analysis_prompt(new_result, historical_data)
    """
    NEW LAB RESULT:
    Date: #{new_result.test_date}
    Lab: #{new_result.lab.name}
    Test: #{new_result.test_name}
    Result: #{new_result.result_value} #{new_result.result_unit}
    Reference Range: #{new_result.reference_range}
    Notes: #{new_result.notes}
    
    HISTORICAL RESULTS (Last 6 months):
    #{historical_data.map { |r| format_lab_result(r) }.join("\n---\n")}
    
    Please provide:
    1. ANOMALY_DETECTION: Identify any concerning changes or patterns
    2. TREND_ANALYSIS: Describe trends across the historical data
    3. RISK_ASSESSMENT: Calculate risk level (LOW/MEDIUM/HIGH/CRITICAL)
    4. RECOMMENDATIONS: Specific actions the patient should take
    5. ALERT_NEEDED: Should we send an immediate alert? (YES/NO)
    6. FOLLOW_UP: Required follow-up tests or consultations
    
    Focus on patterns that span multiple visits and countries.
    Consider the context of travel and different healthcare systems.
    """
  end

  def build_health_profile
    {
      age: patient.age,
      gender: patient.gender,
      conditions: patient.medical_conditions,
      medications: patient.current_medications,
      allergies: patient.allergies,
      recent_labs: patient.lab_results.recent.map(&:summary)
    }
  end

  def fetch_destination_health_data(destination)
    # In production, this would call an API or database
    destinations = {
      'India' => {
        climate: 'Hot and humid (35°C, 80% humidity)',
        diseases: 'Dengue, Malaria, Typhoid, Hepatitis A',
        healthcare_quality: 'Variable - excellent private hospitals in major cities'
      },
      'Canada' => {
        climate: 'Cold winter (-20°C), dry air',
        diseases: 'Seasonal flu, COVID-19 variants',
        healthcare_quality: 'Excellent but long wait times'
      },
      'Dubai' => {
        climate: 'Extreme heat (45°C), very dry',
        diseases: 'MERS, Heat exhaustion risk',
        healthcare_quality: 'Excellent private healthcare'
      }
    }
    
    destinations[destination] || {
      climate: 'Temperate',
      diseases: 'Standard travel risks',
      healthcare_quality: 'Good'
    }
  end

  def format_lab_result(result)
    """
    Date: #{result.test_date.strftime('%Y-%m-%d')}
    Lab: #{result.lab.name}
    Test: #{result.test_name}
    Result: #{result.result_value} #{result.result_unit} (Ref: #{result.reference_range})
    #{result.notes.present? ? "Notes: #{result.notes}" : ""}
    """
  end

  def format_test_values(test_values)
    if test_values.is_a?(Hash)
      test_values.map do |name, data|
        "- #{name}: #{data[:value]} #{data[:unit]} (Ref: #{data[:reference_range]})"
      end.join("\n")
    else
      ""
    end
  end

  def parse_reasoning_output(response)
    output = response['response'] || ''
    
    {
      anomaly_detection: extract_section(output, 'ANOMALY_DETECTION'),
      trend_analysis: extract_section(output, 'TREND_ANALYSIS'),
      risk_assessment: extract_section(output, 'RISK_ASSESSMENT'),
      recommendations: extract_list(output, 'RECOMMENDATIONS'),
      alert_needed: extract_section(output, 'ALERT_NEEDED').include?('YES'),
      follow_up: extract_section(output, 'FOLLOW_UP'),
      raw_output: output,
      timestamp: Time.current
    }
  end

  def parse_travel_advisory(response)
    output = response['response'] || ''
    
    {
      health_risks: extract_list(output, 'HEALTH_RISKS'),
      medication_adjustments: extract_list(output, 'MEDICATION_ADJUSTMENTS'),
      vaccinations: extract_list(output, 'VACCINATIONS'),
      precautions: extract_list(output, 'PRECAUTIONS'),
      emergency_prep: extract_list(output, 'EMERGENCY_PREP'),
      emergency_contacts: extract_list(output, 'LOCAL_HOSPITALS'),
      preparations: extract_list(output, 'PRECAUTIONS') + extract_list(output, 'EMERGENCY_PREP')
    }
  end

  def parse_trend_analysis(response)
    output = response['response'] || ''
    
    {
      trend_analysis: extract_section(output, 'TREND_ANALYSIS'),
      risk_projection: extract_section(output, 'RISK_PROJECTION'),
      intervention_timing: extract_section(output, 'INTERVENTION_TIMING'),
      success_metrics: extract_list(output, 'SUCCESS_METRICS')
    }
  end

  def extract_section(text, section_name)
    regex = /#{section_name}:\s*(.*?)(?=\n[A-Z_]+:|$)/m
    match = text.match(regex)
    match ? match[1].strip : ''
  end

  def extract_list(text, section_name)
    section = extract_section(text, section_name)
    section.split(/\n/).map(&:strip).reject(&:empty?)
          .map { |line| line.gsub(/^\d+\.\s*/, '').gsub(/^-\s*/, '') }
  end

  def should_send_alert?(analysis)
    analysis[:alert_needed] || 
    ['HIGH', 'CRITICAL'].include?(analysis[:risk_assessment])
  end

  def critical_value?(test_name, value)
    critical_thresholds = {
      'Creatinine' => { high: 2.0 },
      'Glucose' => { high: 200, low: 50 },
      'Potassium' => { high: 5.5, low: 3.0 },
      'Hemoglobin' => { low: 7.0 },
      'Platelet' => { low: 50000 }
    }
    
    threshold = critical_thresholds[test_name]
    return false unless threshold
    
    value = value.to_f
    (threshold[:high] && value > threshold[:high]) ||
    (threshold[:low] && value < threshold[:low])
  end

  def analyze_trends(results)
    trends = { improving: [], worsening: [], stable: [], concerning: [] }
    
    # Group by test type
    tests_over_time = {}
    results.each do |result|
      test_name = result.test_name
      tests_over_time[test_name] ||= []
      tests_over_time[test_name] << {
        value: result.result_value.to_f,
        date: result.test_date
      }
    end
    
    # Analyze each test's trend
    tests_over_time.each do |test_name, values|
      next if values.size < 2
      
      values.sort_by! { |v| v[:date] }
      
      # Simple trend detection
      first_value = values.first[:value]
      last_value = values.last[:value]
      change_percent = ((last_value - first_value) / first_value * 100).abs
      
      if change_percent > 20
        if last_value > first_value
          trends[:worsening] << test_name
          trends[:concerning] << {
            type: 'WORSENING_TREND',
            test: test_name,
            change: "+#{change_percent.round}%",
            period: "#{(values.last[:date] - values.first[:date]).to_i / 86400} days"
          }
        else
          trends[:improving] << test_name
        end
      else
        trends[:stable] << test_name
      end
    end
    
    trends
  end

  def store_analysis(lab_result, analysis)
    AiAnalysis.create!(
      patient: lab_result.patient,
      analyzable: lab_result,
      analysis_type: 'lab_result_analysis',
      reasoning_output: analysis.to_json,
      risk_assessment: analysis[:risk_level],
      recommendations: analysis[:recommendations].to_json,
      alert_sent: false
    )
  end
end