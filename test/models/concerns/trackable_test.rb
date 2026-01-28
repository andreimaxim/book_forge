require "test_helper"

# We need a model that includes Trackable to test the concern.
# Author is a good candidate as it has a status field.
class TrackableTest < ActiveSupport::TestCase
  test "logs activity on record creation" do
    author = Author.create!(
      first_name: "Test",
      last_name: "Author",
      status: "active"
    )

    activity = Activity.for_trackable("Author", author.id).by_action("created").first

    assert_not_nil activity, "Expected an activity to be created for the new author"
    assert_equal "created", activity.action
    assert_equal "Author", activity.trackable_type
    assert_equal author.id, activity.trackable_id
  end

  test "logs activity on record update" do
    author = authors(:jane_austen)
    original_bio = author.bio

    author.update!(bio: "Updated biography for testing")

    activity = Activity.for_trackable("Author", author.id).by_action("updated").first

    assert_not_nil activity, "Expected an activity to be created for the updated author"
    assert_equal "updated", activity.action
    assert_equal "bio", activity.field_changed
    assert_equal original_bio, activity.old_value
    assert_equal "Updated biography for testing", activity.new_value
  end

  test "logs activity on status change" do
    author = authors(:jane_austen)
    assert_equal "active", author.status

    author.update!(status: "inactive")

    activity = Activity.for_trackable("Author", author.id).by_action("status_changed").first

    assert_not_nil activity, "Expected a status_changed activity to be created"
    assert_equal "status_changed", activity.action
    assert_equal "status", activity.field_changed
    assert_equal "active", activity.old_value
    assert_equal "inactive", activity.new_value
  end

  test "logs activity on record deletion" do
    author = authors(:author_without_books)
    author_id = author.id

    author.destroy!

    # The activity should exist even though the author is deleted
    # Since we use before_destroy, the activity is created before the record is gone
    activity = Activity.where(trackable_type: "Author", trackable_id: author_id).by_action("updated").last

    assert_not_nil activity, "Expected an activity to be created before author deletion"
    assert_match(/deleted/, activity.description)
  end

  test "captures old and new values for changes" do
    author = authors(:jane_austen)
    old_website = author.website
    new_website = "https://newsite.example.com"

    author.update!(website: new_website)

    activity = Activity.for_trackable("Author", author.id)
                       .where(field_changed: "website")
                       .first

    assert_not_nil activity
    assert_equal old_website, activity.old_value
    assert_equal new_website, activity.new_value
  end

  test "does not log activity for unchanged saves" do
    author = authors(:jane_austen)

    # Get the count of activities before saving without changes
    initial_count = Activity.for_trackable("Author", author.id).count

    # Save without making any changes
    author.save!

    # Count should remain the same
    final_count = Activity.for_trackable("Author", author.id).count

    assert_equal initial_count, final_count, "No activity should be logged for unchanged saves"
  end

  test "includes changed fields in activity" do
    author = authors(:jane_austen)

    author.update!(
      phone: "555-9999",
      notes: "Updated notes for testing"
    )

    # Should have created activities for both changed fields
    phone_activity = Activity.for_trackable("Author", author.id)
                             .where(field_changed: "phone")
                             .first

    notes_activity = Activity.for_trackable("Author", author.id)
                             .where(field_changed: "notes")
                             .first

    assert_not_nil phone_activity, "Expected activity for phone field change"
    assert_equal "phone", phone_activity.field_changed
    assert_equal "555-9999", phone_activity.new_value

    assert_not_nil notes_activity, "Expected activity for notes field change"
    assert_equal "notes", notes_activity.field_changed
    assert_equal "Updated notes for testing", notes_activity.new_value
  end
end
