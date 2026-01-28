# frozen_string_literal: true

module Trackable
  extend ActiveSupport::Concern

  included do
    has_many :activities, as: :trackable, dependent: :destroy

    after_create :log_creation_activity
    after_update :log_update_activity
    before_destroy :log_deletion_activity
  end

  private

  def log_creation_activity
    Activity.create!(
      trackable_type: self.class.name,
      trackable_id: id,
      action: "created",
      description: "#{self.class.name} was created"
    )
  end

  def log_update_activity
    return if saved_changes.except("updated_at").empty?

    if saved_changes.key?("status")
      log_status_change_activity
    else
      log_field_changes_activity
    end
  end

  def log_status_change_activity
    old_status, new_status = saved_changes["status"]

    Activity.create!(
      trackable_type: self.class.name,
      trackable_id: id,
      action: "status_changed",
      field_changed: "status",
      old_value: old_status,
      new_value: new_status,
      description: "Status changed from #{old_status} to #{new_status}"
    )
  end

  def log_field_changes_activity
    changes = saved_changes.except("updated_at", "created_at")
    return if changes.empty?

    changes.each do |field, (old_value, new_value)|
      Activity.create!(
        trackable_type: self.class.name,
        trackable_id: id,
        action: "updated",
        field_changed: field,
        old_value: old_value.to_s,
        new_value: new_value.to_s,
        description: "#{field.humanize} was updated"
      )
    end
  end

  def log_deletion_activity
    Activity.create!(
      trackable_type: self.class.name,
      trackable_id: id,
      action: "updated",
      description: "#{self.class.name} was deleted"
    )
  end
end
