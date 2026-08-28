class Newspaper < ApplicationRecord
  has_many :screenshots, dependent: :restrict_with_error

  before_validation :set_slug

  validates :name, :slug, :homepage_url, :time_zone, :capture_time, presence: true
  validates :slug, uniqueness: true
  validates :homepage_url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validate :at_least_one_viewport

  scope :active, -> { where(active: true) }
  scope :alphabetical, -> { order(:name) }

  private
    def set_slug
      self.slug = name.to_s.parameterize if slug.blank?
    end

    def at_least_one_viewport
      errors.add(:base, "selecione desktop ou mobile") unless desktop_enabled? || mobile_enabled?
    end
end
