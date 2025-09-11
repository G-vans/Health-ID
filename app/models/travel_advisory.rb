class TravelAdvisory < ApplicationRecord
  belongs_to :patient
  
  validates :destination, presence: true
  validates :departure_date, presence: true
  
  scope :upcoming, -> { where('departure_date >= ?', Date.current) }
  scope :recent, -> { order(created_at: :desc) }
  
  def active?
    departure_date >= Date.current && departure_date <= 30.days.from_now
  end
  
  def formatted_health_risks
    health_risks.is_a?(Array) ? health_risks : JSON.parse(health_risks || '[]')
  end
  
  def formatted_preparations
    preparations.is_a?(Array) ? preparations : JSON.parse(preparations || '[]')
  end
  
  def formatted_emergency_contacts
    emergency_contacts.is_a?(Array) ? emergency_contacts : JSON.parse(emergency_contacts || '[]')
  end
end