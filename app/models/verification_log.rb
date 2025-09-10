class VerificationLog < ApplicationRecord
  belongs_to :credential
  belongs_to :verifier, polymorphic: true

  validates :verification_result, inclusion: { in: %w[success failed expired revoked] }
  validates :verified_at, presence: true

  scope :successful, -> { where(verification_result: 'success') }
  scope :failed, -> { where(verification_result: %w[failed expired revoked]) }
  scope :recent, -> { order(verified_at: :desc) }

  def self.log_verification(credential, verifier, result, details = {})
    create!(
      credential: credential,
      verifier: verifier,
      verification_result: result,
      verified_at: Time.current,
      ip_address: details[:ip_address],
      user_agent: details[:user_agent],
      additional_data: details.to_json
    )
  end
end