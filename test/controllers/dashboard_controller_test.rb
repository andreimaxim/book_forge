require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "displays dashboard with metrics" do
    get root_path

    assert_response :ok
    assert_select "h1", "Dashboard"

    # Metric cards should be present
    assert_select "[data-testid='metric-card']", minimum: 4

    # Key metrics should be displayed
    assert_select "[data-testid='metric-active-authors']"
    assert_select "[data-testid='metric-active-deals']"
    assert_select "[data-testid='metric-total-advance']"
    assert_select "[data-testid='metric-conversion-rate']"
  end

  test "displays dashboard with empty state when no data" do
    # Remove all data
    Deal.delete_all
    Book.delete_all
    Representation.delete_all
    Activity.delete_all
    Note.delete_all
    Prospect.delete_all
    Author.delete_all
    Publisher.delete_all
    Agent.delete_all

    get root_path

    assert_response :ok
    assert_select "h1", "Dashboard"

    # Should show zero values, not errors
    assert_select "[data-testid='metric-active-authors']", text: /0/
    assert_select "[data-testid='metric-active-deals']", text: /0/
    assert_select "[data-testid='metric-conversion-rate']", text: /0/
  end

  test "shows correct metrics for current period" do
    travel_to Date.new(2026, 1, 28) do
      get root_path

      assert_response :ok

      # Deals this month: negotiating_deal (Jan 10), pending_contract_deal (Jan 5),
      # no_advance_deal (Jan 20), this_quarter_deal (Jan 15) = 4
      assert_select "[data-testid='metric-deals-this-month']", text: /4/
    end
  end

  test "shows comparison to previous period" do
    travel_to Date.new(2026, 1, 28) do
      get root_path

      assert_response :ok

      # The dashboard should show change indicators (up/down arrows or percentage)
      assert_select "[data-testid='metric-change']", minimum: 1
    end
  end

  test "displays recent items" do
    get root_path

    assert_response :ok

    # Recent items section should be present
    assert_select "[data-testid='recent-items']"
    assert_select "[data-testid='recent-item']", minimum: 1
  end

  test "caches expensive metric calculations" do
    # The metrics object should be assigned once and reused
    metrics = Dashboard::Metrics.new
    Dashboard::Metrics.expects(:new).once.returns(metrics)

    get root_path

    assert_response :ok
  end

  test "displays pipeline summary" do
    get root_path

    assert_response :ok

    # Pipeline summary section should show books by status and deals by status
    assert_select "[data-testid='pipeline-summary']"
    assert_select "[data-testid='books-by-status']"
    assert_select "[data-testid='deals-by-status']"
  end

  test "displays quick action buttons" do
    get root_path

    assert_response :ok

    # Quick action buttons should be present
    assert_select "[data-testid='quick-actions']"
    assert_select "a[href='#{new_author_path}']", text: /New Author/
    assert_select "a[href='#{new_book_path}']", text: /New Book/
    assert_select "a[href='#{new_deal_path}']", text: /New Deal/
    assert_select "a[href='#{new_prospect_path}']", text: /New Prospect/
  end
end
