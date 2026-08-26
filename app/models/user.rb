class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :activity_logs, dependent: :restrict_with_error

  enum :role, { member: 0, admin: 1 }, default: :member

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }

  scope :active, -> { where(active: true) }
end
