class Book < ApplicationRecord
  include Notable
  include Trackable

  # Constants
  STATUSES = %w[manuscript submitted under_review accepted in_production published out_of_print].freeze
  FORMATS = %w[hardcover paperback ebook audiobook].freeze

  # ISBN regex patterns:
  # ISBN-10: 10 digits, optionally with hyphens (e.g., "0-306-40615-2" or "0306406152")
  # ISBN-13: 13 digits starting with 978 or 979, optionally with hyphens (e.g., "978-0-14-143951-8" or "9780141439518")
  ISBN_REGEX = /\A(?:(?:\d[- ]?){9}[\dXx]|(?:97[89][- ]?)?(?:\d[- ]?){9}[\dXx])\z/

  # Associations
  belongs_to :author, counter_cache: true, touch: true
  has_many :deals, dependent: :restrict_with_error

  # Validations
  validates :title, presence: true
  validates :genre, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :format, inclusion: { in: FORMATS }, allow_blank: true

  validates :word_count, numericality: { greater_than: 0 }, allow_nil: true
  validates :list_price, numericality: { greater_than: 0 }, allow_nil: true
  validates :page_count, numericality: { greater_than: 0, only_integer: true }, allow_nil: true

  validates :isbn, format: { with: ISBN_REGEX }, allow_blank: true
  validates :isbn, uniqueness: true, allow_blank: true

  validate :publication_date_not_in_future_for_published_books

  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :by_genre, ->(genre) { where(genre: genre) }
  scope :by_author, ->(author) { where(author: author) }
  scope :published, -> { where(status: "published") }
  scope :manuscripts_awaiting_deals, -> { where(status: "manuscript") }

  scope :search, ->(query) {
    left_joins(:author)
      .where(
        "books.title ILIKE :query OR books.isbn ILIKE :query OR " \
        "authors.first_name ILIKE :query OR authors.last_name ILIKE :query",
        query: "%#{query}%"
      )
  }

  # Instance methods
  def published?
    status == "published"
  end

  def has_active_deals?
    deals.exists?(status: %w[negotiating pending_contract signed active])
  end

  def days_since_submission
    return nil unless status.in?(%w[submitted under_review accepted in_production published])
    (Date.current - created_at.to_date).to_i
  end

  def formatted_word_count
    return nil if word_count.nil?
    "#{word_count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} words"
  end

  private

  def publication_date_not_in_future_for_published_books
    return unless status == "published" && publication_date.present?
    if publication_date > Date.current
      errors.add(:publication_date, "can't be in the future for published books")
    end
  end
end
