class Representation < ApplicationRecord
  # Enums
  enum :status, %w[active ended].index_by(&:itself)

  # Associations
  belongs_to :author, touch: true
  belongs_to :agent, counter_cache: true, touch: true

  # Validations
  validates :author_id, uniqueness: { scope: :agent_id }
  validates :status, presence: true
  validate :end_date_after_start_date

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :ended, -> { where(status: "ended") }

  # Callbacks
  before_validation :set_default_start_date, on: :create
  before_save :unset_other_primary_representations, if: :primary?

  # Instance methods
  def end_representation!
    update!(status: "ended", end_date: Date.current)
  end

  def current?
    status == "active"
  end

  def duration_in_days
    return nil if start_date.blank?
    end_point = end_date || Date.current
    (end_point - start_date).to_i
  end

  private

  def set_default_start_date
    self.start_date ||= Date.current
  end

  def unset_other_primary_representations
    Representation.where(author_id: author_id, primary: true)
                  .where.not(id: id)
                  .update_all(primary: false)
  end


  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    return if end_date > start_date

    errors.add(:end_date, "must be after start date")
  end
end
