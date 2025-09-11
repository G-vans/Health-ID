class Patient < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :connections
  has_many :connected_organizations, through: :connections, source: :company
  has_many :credentials, foreign_key: :holder_id
  has_many :access_requests
  has_many :lab_results, dependent: :destroy
  has_many :credential_shares, dependent: :destroy
  has_many :verification_logs, through: :credential_shares
  has_many :ai_analyses, dependent: :destroy
  has_many :travel_advisories, dependent: :destroy
  has_many :notification_logs, dependent: :destroy

  def pending_requests
    access_requests.where(status: 'pending')
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
  
  def age
    return nil unless date_of_birth
    ((Time.zone.now - date_of_birth.to_time) / 1.year.seconds).floor
  end
  
  def medical_conditions
    # This would come from a separate model in production
    []
  end
  
  def current_medications
    # This would come from a separate model in production
    []
  end
  
  def allergies
    # This would come from a separate model in production
    []
  end
end
