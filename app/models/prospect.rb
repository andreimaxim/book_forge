class Prospect < ApplicationRecord
  include Notable
  include Trackable

  # Enums
  enum :stage, %w[new contacted evaluating negotiating converted declined].index_by(&:itself), prefix: true
  enum :source, %w[query_letter referral conference social_media website other].index_by(&:itself)

  # Valid stage transitions: current_stage => [allowed_next_stages]
  STAGE_TRANSITIONS = {
    "new" => %w[contacted declined],
    "contacted" => %w[evaluating declined],
    "evaluating" => %w[negotiating declined],
    "negotiating" => %w[converted declined],
    "converted" => [],
    "declined" => []
  }.freeze

  # Associations
  belongs_to :agent, optional: true

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :stage, presence: true
  validates :estimated_word_count, numericality: { greater_than: 0 }, allow_nil: true

  # Scopes
  scope :recent, -> { order(updated_at: :desc) }
  scope :by_stage, ->(stage) { where(stage: stage) }
  scope :by_source, ->(source) { where(source: source) }
  scope :follow_up_today, -> { where(follow_up_date: Date.today) }
  scope :follow_up_this_week, -> {
    where(follow_up_date: Date.today..Date.today.end_of_week)
  }
  scope :overdue_follow_up, -> { where("follow_up_date < ?", Date.today) }
  scope :unassigned, -> { where(agent_id: nil) }
  scope :alphabetical, -> { order(:last_name, :first_name) }
  scope :search, ->(query) {
    where(
      "first_name ILIKE :query OR last_name ILIKE :query OR project_title ILIKE :query",
      query: "%#{query}%"
    )
  }

  # Active pipeline (not converted or declined)
  scope :active, -> { where.not(stage: %w[converted declined]) }

  # Class methods
  def self.workflow_stages
    stages.keys - %w[converted declined]
  end

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def transition_to!(new_stage)
    allowed_stages = STAGE_TRANSITIONS[stage] || []

    if allowed_stages.empty?
      errors.add(:stage, "cannot transition from #{stage}")
      return false
    end

    unless allowed_stages.include?(new_stage)
      errors.add(:stage, "cannot transition from #{stage} to #{new_stage}")
      return false
    end

    self.stage = new_stage
    self.stage_changed_at = Time.current
    save
  end

  def convert_to_author!
    if stage == "converted"
      errors.add(:stage, "prospect has already been converted")
      return nil
    end

    unless stage == "negotiating"
      errors.add(:stage, "must be in negotiating stage to convert")
      return nil
    end

    author = Author.new(
      first_name: first_name,
      last_name: last_name,
      email: email,
      phone: phone,
      genre_focus: genre_interest,
      status: "active",
      notes: "Converted from prospect. Project: #{project_title}"
    )

    if author.save
      self.stage = "converted"
      self.stage_changed_at = Time.current
      save
      author
    else
      errors.merge!(author.errors)
      nil
    end
  end

  def decline!(reason)
    if reason.blank?
      errors.add(:decline_reason, "is required when declining")
      return false
    end

    allowed_stages = STAGE_TRANSITIONS[stage] || []

    if allowed_stages.empty?
      errors.add(:stage, "cannot transition from #{stage}")
      return false
    end

    unless allowed_stages.include?("declined")
      errors.add(:stage, "cannot decline from #{stage}")
      return false
    end

    self.stage = "declined"
    self.decline_reason = reason
    self.stage_changed_at = Time.current
    save
  end

  def days_in_current_stage
    return 0 if stage_changed_at.nil?

    ((Time.current - stage_changed_at) / 1.day).floor
  end

  def stage_past?(other_stage)
    return false if stage == "converted" || stage == "declined"

    self.class.workflow_stages.index(stage) > self.class.workflow_stages.index(other_stage)
  end

  def convertible?
    stage == "negotiating"
  end

  def declinable?
    stage != "converted" && stage != "declined"
  end

  def follow_up_overdue?
    follow_up_date.present? && follow_up_date < Date.current
  end

  def follow_up_today?
    follow_up_date.present? && follow_up_date == Date.current
  end
end
