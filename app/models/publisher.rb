class Publisher < ApplicationRecord
  include Notable
  include Trackable

  # Constants
  SIZES = %w[big_five major mid_size small indie].freeze
  STATUSES = %w[active inactive].freeze

  # Associations
  has_many :deals, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :website, format: { with: %r{\Ahttps?://\S+\z} }, allow_blank: true
  validates :size, inclusion: { in: SIZES }, allow_blank: true
  validates :status, inclusion: { in: STATUSES }

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :by_size, ->(size) { where(size: size) }
  scope :alphabetical, -> { order(:name) }
  scope :search, ->(query) {
    where("name ILIKE :query", query: "%#{query}%")
  }

  # Instance methods
  def full_address
    return nil if address_line1.blank?

    parts = []
    parts << address_line1
    parts << address_line2 if address_line2.present?
    parts << city_state_postal if city.present? || state.present? || postal_code.present?
    parts << country if country.present?

    parts.join("\n")
  end

  def big_five?
    size == "big_five"
  end

  def display_name
    if imprint.present?
      "#{name} (#{imprint})"
    else
      name
    end
  end

  private

  def city_state_postal
    # Format: "City, State PostalCode"
    city_part = city
    state_postal = [ state, postal_code ].compact_blank.join(" ")

    if city_part.present? && state_postal.present?
      "#{city_part}, #{state_postal}"
    elsif city_part.present?
      city_part
    else
      state_postal
    end
  end
end
