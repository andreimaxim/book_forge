class Deal < ApplicationRecord
  include Notable
  include Trackable

  # Constants
  DEAL_TYPES = %w[world_rights north_american translation audio film_tv].freeze
  STATUSES = %w[negotiating pending_contract signed active completed terminated].freeze

  CURRENCY_SYMBOLS = {
    "USD" => "$",
    "EUR" => "\u20AC",
    "GBP" => "\u00A3",
    "CAD" => "C$",
    "AUD" => "A$"
  }.freeze

  # Associations
  belongs_to :book, touch: true
  belongs_to :publisher, counter_cache: true, touch: true
  belongs_to :agent, optional: true, touch: true

  # Validations
  validates :deal_type, presence: true, inclusion: { in: DEAL_TYPES }
  validates :status, inclusion: { in: STATUSES }
  validates :advance_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :royalty_rate_hardcover, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }, allow_nil: true
  validates :royalty_rate_paperback, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }, allow_nil: true
  validates :royalty_rate_ebook, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }, allow_nil: true
  validates :book_id, uniqueness: {
    scope: :publisher_id,
    message: "already has a deal with this publisher. A duplicate deal already exists."
  }

  validate :contract_date_after_offer_date
  validate :delivery_date_after_contract_date

  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :by_deal_type, ->(deal_type) { where(deal_type: deal_type) }
  scope :by_publisher, ->(publisher) { where(publisher: publisher) }
  scope :by_agent, ->(agent) { where(agent: agent) }

  scope :active, -> { where(status: %w[negotiating pending_contract signed active]) }

  scope :this_year, -> {
    where(offer_date: Date.current.beginning_of_year..Date.current.end_of_year)
  }

  scope :this_quarter, -> {
    where(offer_date: Date.current.beginning_of_quarter..Date.current.end_of_quarter)
  }

  scope :search, ->(query) {
    left_joins(book: :author)
      .where(
        "books.title ILIKE :query OR " \
        "authors.first_name ILIKE :query OR authors.last_name ILIKE :query",
        query: "%#{query}%"
      )
  }

  # Instance methods
  def agent_commission
    return 0.00 if agent.nil? || advance_amount.nil? || advance_amount.zero?
    (advance_amount * agent.commission_rate / 100.0).round(2)
  end

  def author_net_advance
    return 0.00 if advance_amount.nil? || advance_amount.zero?
    advance_amount - agent_commission
  end

  def total_deal_value
    advance_amount || 0.00
  end

  def formatted_advance
    amount = advance_amount || 0.00
    symbol = CURRENCY_SYMBOLS[advance_currency] || "$"
    "#{symbol}#{format('%.2f', amount).reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def signed?
    status.in?(%w[signed active completed])
  end

  def days_to_close
    return nil if offer_date.nil? || contract_date.nil?
    (contract_date - offer_date).to_i
  end

  private

  def contract_date_after_offer_date
    return if offer_date.blank? || contract_date.blank?
    if contract_date < offer_date
      errors.add(:contract_date, "must be after offer date")
    end
  end

  def delivery_date_after_contract_date
    return if contract_date.blank? || delivery_date.blank?
    if delivery_date < contract_date
      errors.add(:delivery_date, "must be after contract date")
    end
  end
end
