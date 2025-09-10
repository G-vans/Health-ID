class Patient < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :connections
  has_many :connected_organizations, through: :connections, source: :company
  has_many :credentials, foreign_key: :holder_id
  has_many :access_requests

  def pending_requests
    access_requests.where(status: 'PENDING')
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
