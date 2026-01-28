require "test_helper"

class ActivityTest < ActiveSupport::TestCase
  test "requires trackable" do
    activity = Activity.new(trackable_type: nil, trackable_id: nil, action: "created")
    assert_not activity.valid?
    assert_includes activity.errors[:trackable_type], "can't be blank"
    assert_includes activity.errors[:trackable_id], "can't be blank"
  end

  test "requires action" do
    activity = Activity.new(trackable_type: "Author", trackable_id: 1, action: nil)
    assert_not activity.valid?
    assert_includes activity.errors[:action], "can't be blank"
  end

  test "validates action is a known value" do
    activity = Activity.new(
      trackable_type: "Author",
      trackable_id: 1,
      action: "unknown_action"
    )
    assert_not activity.valid?
    assert_includes activity.errors[:action], "is not included in the list"
  end

  test "allows all known action values" do
    known_actions = %w[
      created updated status_changed field_changed
      note_added note_updated note_deleted
      representation_added representation_ended
      deal_created
    ]

    known_actions.each do |valid_action|
      activity = Activity.new(
        trackable_type: "Author",
        trackable_id: 1,
        action: valid_action
      )
      assert activity.valid?, "Expected action '#{valid_action}' to be valid"
    end
  end

  test "scopes activities by trackable" do
    author = authors(:jane_austen)
    author_activities = Activity.for_trackable("Author", author.id)

    assert_includes author_activities, activities(:author_created)
    assert_includes author_activities, activities(:author_status_changed)
    assert_includes author_activities, activities(:note_added)
    assert_includes author_activities, activities(:author_note_updated)

    # Should NOT include activities for other trackables
    assert_not_includes author_activities, activities(:book_field_changed)
    assert_not_includes author_activities, activities(:deal_created)
    assert_not_includes author_activities, activities(:representation_added) # Different trackable_id
  end

  test "scopes activities by action type" do
    created_activities = Activity.by_action("created")

    assert_includes created_activities, activities(:author_created)
    assert_includes created_activities, activities(:old_activity)
    assert_not_includes created_activities, activities(:author_status_changed)
    assert_not_includes created_activities, activities(:note_added)
  end

  test "scopes activities in date range" do
    # Activities in the last week (excludes old_activity which is 10 days ago)
    recent_activities = Activity.in_date_range(7.days.ago, Time.current)

    assert_includes recent_activities, activities(:author_created)
    assert_includes recent_activities, activities(:author_status_changed)
    assert_includes recent_activities, activities(:book_field_changed)
    assert_not_includes recent_activities, activities(:old_activity)
  end

  test "scopes recent activities" do
    # Recent activities should be ordered by created_at descending
    recent = Activity.recent

    # The first activity should be the most recent one
    assert_equal activities(:author_note_updated), recent.first

    # Should be ordered descending (newest first)
    created_ats = recent.map(&:created_at)
    assert_equal created_ats.sort.reverse, created_ats
  end

  test "returns human readable description" do
    # Activity with description set
    activity_with_desc = activities(:author_created)
    assert_equal "Author Jane Austen was created", activity_with_desc.human_description

    # Activity with field change should generate description
    activity_field_change = Activity.new(
      trackable_type: "Book",
      trackable_id: 1,
      action: "field_changed",
      field_changed: "word_count",
      old_value: "100000",
      new_value: "120000"
    )
    assert_equal "Word Count changed from 100000 to 120000", activity_field_change.human_description

    # Activity with status change
    activity_status = Activity.new(
      trackable_type: "Author",
      trackable_id: 1,
      action: "status_changed",
      field_changed: "status",
      old_value: "active",
      new_value: "inactive"
    )
    assert_equal "Status changed from active to inactive", activity_status.human_description

    # Activity with just action (created)
    activity_created = Activity.new(
      trackable_type: "Book",
      trackable_id: 1,
      action: "created"
    )
    assert_equal "Book was created", activity_created.human_description
  end

  test "returns formatted timestamp" do
    activity = activities(:author_created)

    # Should return a human-readable timestamp
    formatted = activity.formatted_timestamp

    assert_kind_of String, formatted
    assert formatted.present?

    # Test that it includes date information
    assert_match(/\d/, formatted) # Contains digits (for dates/times)
  end

  test "returns changed field display name" do
    activity = Activity.new(field_changed: "word_count")
    assert_equal "Word Count", activity.field_changed_display_name

    activity = Activity.new(field_changed: "status")
    assert_equal "Status", activity.field_changed_display_name

    activity = Activity.new(field_changed: "publication_date")
    assert_equal "Publication Date", activity.field_changed_display_name

    activity = Activity.new(field_changed: nil)
    assert_nil activity.field_changed_display_name
  end

  test "stores metadata as JSON" do
    activity = Activity.create!(
      trackable_type: "Deal",
      trackable_id: 1,
      action: "deal_created",
      metadata: { publisher_name: "Penguin Books", advance: 50000 }
    )

    # Reload to ensure it's persisted and retrieved correctly
    activity.reload

    assert_kind_of Hash, activity.metadata
    assert_equal "Penguin Books", activity.metadata["publisher_name"]
    assert_equal 50000, activity.metadata["advance"]
  end

  test "metadata defaults to empty hash" do
    activity = Activity.new(
      trackable_type: "Author",
      trackable_id: 1,
      action: "created"
    )

    assert_equal({}, activity.metadata)
  end
end
