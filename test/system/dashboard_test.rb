require "application_system_test_case"

class DashboardSystemTest < ApplicationSystemTestCase
  test "viewing dashboard overview" do
    visit root_path

    assert_selector "h1", text: "Dashboard"

    # Metric cards should be visible
    assert_selector "[data-testid='metric-card']", minimum: 4

    # Key sections should be present
    assert_selector "[data-testid='quick-actions']"
    assert_selector "[data-testid='pipeline-summary']"
    assert_selector "[data-testid='recent-items']"
  end

  test "viewing deal metrics" do
    travel_to Date.new(2026, 1, 28) do
      visit root_path

      # Active authors count should be visible
      within "[data-testid='metric-active-authors']" do
        assert_text Author.active.count.to_s
      end

      # Active deals count should be visible
      within "[data-testid='metric-active-deals']" do
        assert_text Deal.active.count.to_s
      end

      # Deals this month should be visible
      within "[data-testid='metric-deals-this-month']" do
        assert_text "4"
      end

      # Conversion rate should be visible
      within "[data-testid='metric-conversion-rate']" do
        assert_text "%"
      end
    end
  end

  test "viewing pipeline summary" do
    visit root_path

    within "[data-testid='pipeline-summary']" do
      # Books by status should list status categories
      within "[data-testid='books-by-status']" do
        assert_text "Published"
        assert_text "Manuscript"
      end

      # Deals by status should list status categories
      within "[data-testid='deals-by-status']" do
        assert_text "Signed"
        assert_text "Negotiating"
        assert_text "Active"
      end
    end
  end

  test "navigating from dashboard to entity list" do
    visit root_path

    # Click on Authors link in quick actions (opens modal-style page)
    within "[data-testid='quick-actions']" do
      click_link "New Author"
    end

    assert_selector "h2", text: "New Author"

    # Go back to dashboard
    visit root_path

    # Click on Books link in quick actions
    within "[data-testid='quick-actions']" do
      click_link "New Book"
    end

    assert_selector "h1", text: "New Book"
  end

  test "using quick action buttons" do
    visit root_path

    within "[data-testid='quick-actions']" do
      assert_link "New Author"
      assert_link "New Book"
      assert_link "New Deal"
      assert_link "New Prospect"
    end

    # Click on New Deal
    within "[data-testid='quick-actions']" do
      click_link "New Deal"
    end

    assert_selector "h1", text: "New Deal"
  end

  test "viewing recent items" do
    visit root_path

    within "[data-testid='recent-items']" do
      # Should display recently updated records
      assert_selector "[data-testid='recent-item']", minimum: 1

      # Each recent item should have a link to the record
      assert_selector "a[data-testid='recent-item']", minimum: 1
    end
  end
end
