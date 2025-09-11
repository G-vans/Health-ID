class AiAnalysis < ApplicationRecord
  belongs_to :patient
  belongs_to :analyzable, polymorphic: true, optional: true
  
  enum risk_assessment: {
    low: 0,
    medium: 1,
    high: 2,
    critical: 3
  }
  
  enum analysis_type: {
    lab_result_analysis: 0,
    trend_analysis: 1,
    travel_advisory: 2,
    anomaly_detection: 3
  }
  
  scope :recent, -> { where(created_at: 1.month.ago..Time.current) }
  scope :alerts_sent, -> { where(alert_sent: true) }
  scope :high_risk, -> { where(risk_assessment: [:high, :critical]) }
  
  def formatted_recommendations
    recommendations.is_a?(Array) ? recommendations : JSON.parse(recommendations || '[]')
  end
  
  def send_alert!
    return if alert_sent?
    
    HealthAlertJob.perform_later(patient, self)
    update!(alert_sent: true, alert_sent_at: Time.current)
  end
end