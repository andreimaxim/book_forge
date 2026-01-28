require "application_system_test_case"

class ActivitiesSystemTest < ApplicationSystemTestCase
  test "viewing activity timeline on author page" do
    author = authors(:jane_austen)

    visit author_path(author)

    # Should have an activity timeline section
    assert_selector "[data-testid='activity-timeline-section']"

    # Should show recent activities for this author
    within "[data-testid='activity-timeline-section']" do
      assert_text "Activities"
      # Author created and status changed activities exist in fixtures for author ID 1
      assert_selector "[data-testid='activity-item']", minimum: 1
    end

    # Should have a link to view all activities
    within "[data-testid='activity-timeline-section']" do
      assert_link "View All Activities"
    end
  end

  test "viewing activity timeline on deal page" do
    deal = deals(:pride_and_prejudice_deal)

    visit deal_path(deal)

    # Should have an activity timeline section
    assert_selector "[data-testid='activity-timeline-section']"

    # Should show activities for this deal
    within "[data-testid='activity-timeline-section']" do
      assert_text "Activities"
      assert_selector "[data-testid='activity-item']", minimum: 1
    end

    # Should have a link to view all activities
    within "[data-testid='activity-timeline-section']" do
      assert_link "View All Activities"
    end
  end

  test "filtering activities by type" do
    author = authors(:jane_austen)

    # Navigate to full activities page for the author
    visit activities_path(trackable_type: "Author", trackable_id: author.id)

    # Should show all activities initially
    assert_selector "[data-testid='activity-item']", minimum: 1

    # Filter by status_changed action
    select "Status Changed", from: "action_type"
    click_button "Apply Filters"

    # Should show only status_changed activities
    assert_selector "[data-testid='activity-item']", count: 1
    assert_text "Status changed"

    # Clear filters
    click_link "Clear"

    # Should show all activities again
    assert_selector "[data-testid='activity-item']", minimum: 2
  end

  test "loading more activities" do
    author = authors(:jane_austen)

    # Create enough activities to trigger pagination (PER_PAGE = 20)
    25.times do |i|
      Activity.create!(
        trackable_type: "Author",
        trackable_id: author.id,
        action: "updated",
        description: "Test activity #{i + 1} for pagination"
      )
    end

    # Visit the activities page
    visit activities_path(trackable_type: "Author", trackable_id: author.id)

    # Should show pagination
    assert_selector "nav", text: /page 1 of/i

    # Should have Next link on first page
    assert_selector "[data-testid='pagination-next']"

    # Should NOT have Previous link on first page
    assert_no_selector "[data-testid='pagination-prev']"

    # Click Next to load more activities
    click_link "Next"

    # Should now be on page 2
    assert_selector "nav", text: /page 2 of/i

    # Should have Previous link on second page
    assert_selector "[data-testid='pagination-prev']"

    # Click Previous to go back
    click_link "Previous"

    # Should be back on page 1
    assert_selector "nav", text: /page 1 of/i
  end
end
