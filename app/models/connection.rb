class Connection < ApplicationRecord
  belongs_to :patient
  belongs_to :company

  enum status: { pending: 'PENDING', approved: 'APPROVED', denied: 'DENIED' }
end
