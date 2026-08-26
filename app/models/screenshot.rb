class Screenshot < ApplicationRecord
  belongs_to :newspaper
  belongs_to :capture_run

  has_one_attached :image

  enum :viewport, { desktop: 0, mobile: 1 }
  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }, default: :pending

  validates :captured_on, :source_url, :viewport, presence: true
  validates :viewport, uniqueness: { scope: %i[newspaper_id captured_on] }

  scope :recent, -> { order(captured_on: :desc, captured_at: :desc) }
end
