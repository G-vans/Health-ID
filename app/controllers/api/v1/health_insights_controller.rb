# app/controllers/api/v1/health_insights_controller.rb
class Api::V1::HealthInsightsController < ApplicationController
  before_action :authenticate_patient!
  before_action :set_patient
  
  def analyze_lab_results
    lab_result = @patient.lab_results.find(params[:lab_result_id])
    
    service = HealthReasoningService.new(@patient)
    analysis = service.analyze_new_lab_results(lab_result)
    
    render json: {
      status: 'success',
      analysis: analysis,
      risk_level: analysis[:risk_assessment],
      alert_sent: analysis[:alert_needed],
      recommendations: analysis[:recommendations]
    }
  end
  
  def travel_advisory
    destination = params[:destination]
    departure_date = params[:departure_date]
    
    service = HealthReasoningService.new(@patient)
    advisory = service.generate_travel_advisory(destination, departure_date)
    
    render json: {
      status: 'success',
      destination: destination,
      departure_date: departure_date,
      advisory: advisory
    }
  end
  
  def detect_anomalies
    service = HealthReasoningService.new(@patient)
    anomalies = service.detect_anomalies
    
    render json: {
      status: 'success',
      anomalies_found: anomalies.any?,
      anomalies: anomalies,
      total_count: anomalies.count
    }
  end
  
  def trend_analysis
    service = HealthReasoningService.new(@patient)
    trends = service.compare_results_over_time
    
    render json: {
      status: 'success',
      trends: trends
    }
  end
  
  def health_summary
    # Comprehensive health summary using AI
    recent_labs = @patient.lab_results.recent.limit(5)
    recent_analyses = @patient.ai_analyses.recent
    active_advisories = @patient.travel_advisories.upcoming
    
    summary = {
      patient_id: @patient.id,
      last_updated: Time.current,
      health_metrics: {
        total_records: @patient.credentials.count,
        countries_visited: @patient.credentials.pluck(:country).uniq.count,
        recent_alerts: recent_analyses.alerts_sent.count,
        risk_level: recent_analyses.maximum(:risk_assessment) || 'low'
      },
      recent_lab_results: recent_labs.map { |lab| 
        {
          id: lab.id,
          date: lab.created_at,
          location: "#{lab.hospital_name}, #{lab.country}",
          tests_count: lab.test_values.keys.count,
          has_anomalies: lab.ai_analyses.high_risk.any?
        }
      },
      upcoming_travel: active_advisories.map { |advisory|
        {
          destination: advisory.destination,
          departure: advisory.departure_date,
          risks_identified: advisory.health_risks.count
        }
      },
      recommendations: compile_recommendations(recent_analyses)
    }
    
    render json: summary
  end
  
  private
  
  def set_patient
    @patient = current_patient
  end
  
  def compile_recommendations(analyses)
    recommendations = []
    
    analyses.each do |analysis|
      next unless analysis.recommendations.present?
      
      analysis.formatted_recommendations.each do |rec|
        recommendations << {
          source: analysis.analysis_type,
          date: analysis.created_at,
          recommendation: rec,
          priority: analysis.risk_assessment
        }
      end
    end
    
    # Sort by priority and recency
    recommendations.sort_by { |r| [priority_order(r[:priority]), r[:date]] }
                  .reverse
                  .first(5)
  end
  
  def priority_order(priority)
    { 'critical' => 4, 'high' => 3, 'medium' => 2, 'low' => 1 }[priority] || 0
  end
end