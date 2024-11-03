class AccessRequest < ApplicationRecord
  belongs_to :patient
  belongs_to :company

  validates :status, presence: true
end
