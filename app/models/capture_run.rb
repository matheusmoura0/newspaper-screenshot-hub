class CaptureRun < ApplicationRecord
  has_many :screenshots, dependent: :destroy

  enum :status, { pending: 0, running: 1, completed: 2, completed_with_errors: 3, failed: 4 }, default: :pending

  validates :scheduled_for, presence: true, uniqueness: true

  scope :recent, -> { order(scheduled_for: :desc) }
end
