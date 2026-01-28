class Author < ApplicationRecord
  include Notable
  include Trackable

  # Constants
  STATUSES = %w[active inactive deceased].freeze

  # Associations
  has_many :books, dependent: :restrict_with_error
  has_many :representations, dependent: :destroy
  has_many :agents, through: :representations

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :email, uniqueness: true, allow_blank: true
  validates :website, format: { with: %r{\Ahttps?://\S+\z} }, allow_blank: true
  validates :status, inclusion: { in: STATUSES }

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :by_genre, ->(genre) { where(genre_focus: genre) }
  scope :alphabetical, -> { order(:last_name, :first_name) }
  scope :search, ->(query) {
    where(
      "first_name ILIKE :query OR last_name ILIKE :query OR email ILIKE :query",
      query: "%#{query}%"
    )
  }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def initials
    "#{first_name[0]}#{last_name[0]}".upcase
  end
end
