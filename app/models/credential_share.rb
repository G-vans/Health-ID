class CredentialShare < ApplicationRecord
  belongs_to :credential
  belongs_to :verifier, polymorphic: true # Can be Company or another entity
  
  validates :expires_at, presence: true
  validate :expiration_in_future, on: :create

  scope :active, -> { where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  def active?
    expires_at > Time.current
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  def revoked?
    revoked_at.present?
  end

  def accessible?
    active? && !revoked?
  end

  private

  def expiration_in_future
    errors.add(:expires_at, 'must be in the future') if expires_at && expires_at <= Time.current
  end
end