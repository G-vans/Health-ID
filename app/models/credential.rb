class Credential < ApplicationRecord
  belongs_to :issuer, polymorphic: true # Lab or Healthcare Organization
  belongs_to :holder, class_name: 'Patient'
  has_many :credential_shares
  has_many :verification_logs

  validates :credential_type, presence: true
  validates :credential_data, presence: true
  validates :status, inclusion: { in: %w[active revoked expired] }

  encrypts :credential_data # Rails 7 encryption for sensitive data

  scope :active, -> { where(status: 'active') }
  scope :lab_results, -> { where(credential_type: 'lab_result') }

  def verify_signature
    # Verify the credential hasn't been tampered with
    stored_signature = self.signature
    calculated_signature = generate_signature
    stored_signature == calculated_signature
  end

  def share_with(verifier, expires_at: 24.hours.from_now)
    credential_shares.create!(
      verifier: verifier,
      expires_at: expires_at,
      access_granted_at: Time.current
    )
  end

  private

  def generate_signature
    data_to_sign = "#{credential_type}:#{credential_data}:#{issuer_type}:#{issuer_id}:#{issued_at}"
    Digest::SHA256.hexdigest(data_to_sign)
  end
end