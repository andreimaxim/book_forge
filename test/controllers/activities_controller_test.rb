require "test_helper"

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  test "lists activities for a record" do
    # Author with ID 1 has multiple activities in fixtures
    get activities_path(trackable_type: "Author", trackable_id: 1)

    assert_response :ok
    assert_select "h1", /Activities/
    # Should show activities for this author (author_created, author_status_changed, note_added, author_note_updated)
    assert_select "[data-testid='activity-item']", { minimum: 1 }
  end

  test "filters activities by action type" do
    get activities_path(trackable_type: "Author", trackable_id: 1, action_type: "status_changed")

    assert_response :ok
    # Should only show status_changed activities
    assert_select "[data-testid='activity-item']", 1
    assert_select "p.text-sm.text-gray-900", /Status changed/
  end

  test "filters activities by date range" do
    # Based on fixtures, author_created is 3 days ago, author_status_changed is 2 days ago
    # old_activity (Publisher) is 10 days ago - not for this author
    start_date = 4.days.ago.to_date.to_s
    end_date = 1.day.ago.to_date.to_s

    get activities_path(
      trackable_type: "Author",
      trackable_id: 1,
      start_date: start_date,
      end_date: end_date
    )

    assert_response :ok
    # Should show author_created (3 days ago) and author_status_changed (2 days ago)
    # but not note_added (6 hours ago) or author_note_updated (5 minutes ago)
    assert_select "[data-testid='activity-item']", 2
  end

  test "paginates activities" do
    # Create enough activities to test pagination
    # The controller has PER_PAGE = 20, so we need 21+ activities to see pagination
    author = authors(:jane_austen)
    25.times do |i|
      Activity.create!(
        trackable_type: "Author",
        trackable_id: author.id,
        action: "updated",
        description: "Activity #{i} for pagination test"
      )
    end

    # Request first page
    get activities_path(trackable_type: "Author", trackable_id: author.id)

    assert_response :ok
    # Should show pagination info
    assert_select "nav", /page 1 of/i
    # Should have "Next" link but not "Previous" on first page
    assert_select "[data-testid='pagination-next']"
    assert_select "[data-testid='pagination-prev']", 0

    # Request second page
    get activities_path(trackable_type: "Author", trackable_id: author.id, page: 2)

    assert_response :ok
    # Should show pagination info for page 2
    assert_select "nav", /page 2 of/i
    # Should have "Previous" link on second page
    assert_select "[data-testid='pagination-prev']"
  end
end
