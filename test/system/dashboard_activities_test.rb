require "application_system_test_case"

class DashboardActivitiesSystemTest < ApplicationSystemTestCase
  test "viewing activity timeline on dashboard" do
    visit root_path

    # The dashboard should have an activity timeline section
    assert_selector "[data-testid='dashboard-activity-timeline']"

    # Should display activity items
    within "[data-testid='dashboard-activity-timeline']" do
      assert_selector "[data-testid='activity-item']", minimum: 1

      # Activities should be grouped by day
      assert_selector "[data-testid='activity-day-group']", minimum: 1
      assert_selector "[data-testid='activity-day-header']", minimum: 1
    end
  end

  test "filtering activities by entity type" do
    visit root_path

    within "[data-testid='activity-entity-filters']" do
      # Click the Author filter button in the filter tabs
      click_link "Author"
    end

    # Should show only Author activities after filtering
    within "[data-testid='dashboard-activity-timeline']" do
      assert_selector "[data-testid='activity-entity-type']", minimum: 1
      all("[data-testid='activity-entity-type']").each do |element|
        assert_match(/Author/, element.text)
      end
    end
  end

  test "loading more activities" do
    # Create enough activities to require loading more
    author = authors(:jane_austen)
    15.times do |i|
      Activity.create!(
        trackable: author,
        action: "updated",
        description: "Dashboard load more activity #{i}"
      )
    end

    visit root_path

    within "[data-testid='dashboard-activity-timeline']" do
      # Should show initial batch of activities (10 per page)
      assert_selector "[data-testid='activity-item']", count: 10

      # Should have a "Load More" button since there are more than 10 activities
      assert_selector "[data-testid='load-more-activities']"

      # Click load more - this replaces the frame with the next page
      click_button "Load More"

      # The second page should display more activities
      assert_selector "[data-testid='activity-item']", minimum: 1
    end
  end

  test "navigating from activity to related record" do
    visit root_path

    # Find the first activity record link and get its href
    within "[data-testid='dashboard-activity-timeline']" do
      first_link = first("[data-testid='activity-record-link']")
      assert first_link, "Expected at least one activity with a record link"

      @target_href = first_link[:href]
      first_link.click
    end

    # Should navigate to the record's page (not the dashboard root)
    assert_current_path @target_href
  end

  test "activity timeline has turbo frame for real-time updates" do
    visit root_path

    # The activity timeline should be wrapped in a turbo frame for future real-time updates
    assert_selector "turbo-frame#dashboard_activities"
  end
end
