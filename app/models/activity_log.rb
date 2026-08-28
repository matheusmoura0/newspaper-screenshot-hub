class ActivityLog < ApplicationRecord
  belongs_to :user
  belongs_to :auditable, polymorphic: true, optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
