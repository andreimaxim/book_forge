class Activity < ApplicationRecord
  # Constants
  ACTIONS = %w[
    created
    updated
    status_changed
    field_changed
    note_added
    note_updated
    note_deleted
    representation_added
    representation_ended
    deal_created
  ].freeze

  # Associations
  belongs_to :trackable, polymorphic: true, optional: true

  # Validations
  validates :trackable_type, presence: true
  validates :trackable_id, presence: true
  validates :action, presence: true, inclusion: { in: ACTIONS }

  # Scopes
  scope :for_trackable, ->(type, id) { where(trackable_type: type, trackable_id: id) }
  scope :by_action, ->(action) { where(action: action) }
  scope :in_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def field_changed_display_name
    return nil if field_changed.blank?

    field_changed.humanize.titleize
  end

  def human_description
    return description if description.present?

    case action
    when "created"
      "#{trackable_type} was created"
    when "updated"
      "#{trackable_type} was updated"
    when "status_changed"
      "Status changed from #{old_value} to #{new_value}"
    when "field_changed"
      "#{field_changed_display_name} changed from #{old_value} to #{new_value}"
    when "note_added"
      "Note was added"
    when "note_updated"
      "Note was updated"
    when "note_deleted"
      "Note was deleted"
    when "representation_added"
      "Representation was added"
    when "representation_ended"
      "Representation was ended"
    when "deal_created"
      "Deal was created"
    else
      "Activity: #{action}"
    end
  end

  def formatted_timestamp
    created_at.strftime("%B %d, %Y at %l:%M %p")
  end
end
