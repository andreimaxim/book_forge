require "test_helper"

class Dashboard::ActivitiesControllerTest < ActionDispatch::IntegrationTest
  test "lists recent activities" do
    get dashboard_activities_path

    assert_response :ok
    # Should render the activity timeline section
    assert_select "[data-testid='dashboard-activity-timeline']"
    # Should show activity items from fixtures (9 total activities)
    assert_select "[data-testid='activity-item']", minimum: 1
  end

  test "filters activities by entity type" do
    get dashboard_activities_path(entity_type: "Author")

    assert_response :ok
    assert_select "[data-testid='dashboard-activity-timeline']"
    # All displayed activities should be Author activities
    # Fixture has 4 Author activities: author_created, author_status_changed, note_added, author_note_updated
    assert_select "[data-testid='activity-item']", minimum: 1

    # Verify that non-Author activities are NOT shown
    # The Book/Deal/Publisher activities should not appear
    assert_select "[data-testid='activity-entity-type']" do |elements|
      elements.each do |element|
        assert_match(/Author/, element.text)
      end
    end
  end

  test "paginates activities" do
    # Create enough activities to exceed the page size
    author = authors(:jane_austen)
    25.times do |i|
      Activity.create!(
        trackable: author,
        action: "updated",
        description: "Dashboard pagination activity #{i}"
      )
    end

    # First request should show limited activities (page 1)
    get dashboard_activities_path

    assert_response :ok
    assert_select "[data-testid='activity-item']", 10

    # Second page should show more activities
    get dashboard_activities_path(page: 2)

    assert_response :ok
    assert_select "[data-testid='activity-item']", 10
  end

  test "groups activities by day" do
    get dashboard_activities_path

    assert_response :ok
    # Activities should be grouped under day headers
    assert_select "[data-testid='activity-day-group']", minimum: 1
    assert_select "[data-testid='activity-day-header']", minimum: 1
  end

  test "responds with turbo stream for load more" do
    get dashboard_activities_path(page: 2), headers: {
      "Accept" => "text/vnd.turbo-stream.html"
    }

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
  end
end
