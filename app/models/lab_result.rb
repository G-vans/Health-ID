class LabResult < ApplicationRecord
  belongs_to :lab, class_name: 'Company'
  belongs_to :patient
  has_one :credential, as: :issuer, dependent: :destroy

  validates :test_name, presence: true
  validates :result_value, presence: true
  validates :result_unit, presence: true
  validates :reference_range, presence: true
  validates :test_date, presence: true

  # after_create :issue_credential # Temporarily disabled due to encryption config issue

  def to_credential_data
    {
      test_name: test_name,
      result_value: result_value,
      result_unit: result_unit,
      reference_range: reference_range,
      test_date: test_date,
      lab_name: lab.name,
      lab_id: lab.id,
      patient_name: patient.name,
      patient_id: patient.id,
      issued_at: Time.current
    }
  end

  private

  def issue_credential
    Credential.create!(
      issuer: self,
      holder: patient,
      credential_type: 'lab_result',
      credential_data: to_credential_data.to_json,
      status: 'active',
      issued_at: Time.current,
      expires_at: 1.year.from_now,
      signature: generate_signature
    )
  end

  def generate_signature
    data_to_sign = to_credential_data.to_json
    Digest::SHA256.hexdigest(data_to_sign)
  end
end