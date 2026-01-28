class Agent < ApplicationRecord
  include Notable
  include Trackable

  # Constants
  STATUSES = %w[active inactive not_accepting].freeze

  # Associations
  has_many :deals, dependent: :nullify
  has_many :prospects, dependent: :nullify
  has_many :representations, dependent: :destroy
  has_many :authors, through: :representations

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :email, uniqueness: true, allow_blank: true
  validates :commission_rate, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }, allow_nil: true
  validates :status, inclusion: { in: STATUSES }

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :accepting_clients, -> { where(status: "active") }
  scope :by_agency, ->(agency) { where(agency_name: agency) }
  scope :by_genre, ->(genre) {
    where("genres_represented ILIKE ?", "%#{genre}%")
  }
  scope :alphabetical, -> { order(:last_name, :first_name) }
  scope :search, ->(query) {
    where(
      "first_name ILIKE :query OR last_name ILIKE :query OR agency_name ILIKE :query",
      query: "%#{query}%"
    )
  }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_with_agency
    if agency_name.present?
      "#{full_name} (#{agency_name})"
    else
      full_name
    end
  end

  def genres_array
    return [] if genres_represented.blank?
    genres_represented.split(",").map(&:strip)
  end

  def genres_array=(genres)
    self.genres_represented = genres.present? ? genres.join(", ") : nil
  end

  def commission_for(amount)
    return 0.00 if commission_rate.nil?
    (amount * commission_rate / 100.0).round(2)
  end
end
