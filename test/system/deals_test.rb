require "application_system_test_case"

class DealsSystemTest < ApplicationSystemTestCase
  test "viewing the deals list" do
    visit deals_path

    assert_selector "h1", text: "Deals"

    # Verify deals from fixtures are displayed
    assert_text "Pride and Prejudice"
    assert_text "The Shining"
    assert_text "The Untold Story"

    # Verify table structure (default is list view)
    assert_selector "[data-testid='deals-table']"
    assert_selector "[data-testid='deal-row']", minimum: 3

    # Verify key columns are present (headers are uppercase)
    within "[data-testid='deals-table']" do
      assert_selector "th", text: /Book/i
      assert_selector "th", text: /Publisher/i
      assert_selector "th", text: /Type/i
      assert_selector "th", text: /Advance/i
      assert_selector "th", text: /Status/i
    end
  end

  test "viewing deals in pipeline view" do
    visit deals_path

    # Default should be list view
    assert_selector "[data-testid='deals-table']"

    # Switch to pipeline view
    click_link "Pipeline View"

    # Should now show pipeline columns for each status
    assert_selector "[data-testid='pipeline-status-negotiating']"
    assert_selector "[data-testid='pipeline-status-pending_contract']"
    assert_selector "[data-testid='pipeline-status-signed']"
    assert_selector "[data-testid='pipeline-status-active']"

    # Deals should appear in correct columns
    within "[data-testid='pipeline-status-negotiating']" do
      assert_text "The Untold Story"
    end

    within "[data-testid='pipeline-status-signed']" do
      assert_text "Pride and Prejudice"
    end

    # Switch back to list view
    click_link "List View"
    assert_selector "[data-testid='deals-table']"
  end

  test "filtering deals by status" do
    visit deals_path

    # Initially should show all deals
    assert_text "Pride and Prejudice"  # signed
    assert_text "The Untold Story"     # negotiating

    # Filter by negotiating status
    select "Negotiating", from: "Status"
    click_button "Filter"

    # Should show negotiating deals
    assert_text "The Untold Story"

    # Should not show signed deals
    assert_no_text "Pride and Prejudice"

    # Clear filter
    click_link "Clear"

    # Now should show all deals again
    assert_text "Pride and Prejudice"
    assert_text "The Untold Story"
  end

  test "creating a new deal" do
    visit deals_path
    click_link "New Deal"

    assert_selector "h1", text: "New Deal"

    # Fill in the deal form
    select "Pride and Prejudice by Jane Austen", from: "Book"
    select "Scholastic Corporation", from: "Publisher"
    select "Emily Davis (Romance Literary Agency)", from: "Agent (Optional)"
    select "Translation", from: "Deal Type"
    select "Negotiating", from: "Status"

    fill_in "Advance Amount", with: "75000"
    select "USD ($)", from: "Currency"

    fill_in "Hardcover Royalty %", with: "12"
    fill_in "Paperback Royalty %", with: "8"
    fill_in "E-book Royalty %", with: "20"

    # Use execute_script to set date values directly
    page.execute_script("document.querySelector('input[name=\"deal[offer_date]\"]').value = '2026-01-15'")

    fill_in "Terms Summary", with: "Translation rights for Spanish markets"
    fill_in "Notes", with: "New deal for testing"

    click_button "Create Deal"

    # Should redirect to deal show page
    assert_text "Deal was successfully created"
    assert_text "Pride and Prejudice"
    assert_text "Scholastic Corporation"
    assert_text "Translation"
    assert_text "$75,000.00"
  end

  test "viewing deal financial summary" do
    # Use a deal with an agent to see commission calculations
    # pride_and_prejudice_deal has romance_agent with 12.5% commission
    deal = deals(:pride_and_prejudice_deal)

    visit deal_path(deal)

    # Verify the financial summary section is present
    assert_selector "[data-testid='financial-summary']"

    within "[data-testid='financial-summary']" do
      # Check advance amount is displayed
      assert_text "$500,000.00"

      # Check agent commission is displayed (12.5% of 500,000 = 62,500)
      assert_text "Agent Commission"
      assert_text "12.5%"
      assert_text "$62,500.00"

      # Check author net advance (500,000 - 62,500 = 437,500)
      assert_text "Author Net Advance"
      assert_text "$437,500.00"

      # Check royalty rates
      assert_text "15.0%"  # Hardcover
      assert_text "10.0%"  # Paperback
      assert_text "25.0%"  # E-book
    end
  end

  test "updating deal terms" do
    deal = deals(:negotiating_deal)

    visit edit_deal_path(deal)

    assert_selector "h1", text: "Edit Deal"

    # Update financial terms
    fill_in "Advance Amount", with: "150000"
    fill_in "Hardcover Royalty %", with: "14"
    fill_in "Paperback Royalty %", with: "10"
    fill_in "E-book Royalty %", with: "22"
    fill_in "Terms Summary", with: "Updated terms with better advance"

    click_button "Update Deal"

    # Should redirect to show page with updated details
    assert_text "Deal was successfully updated"
    assert_text "$150,000.00"
    assert_text "14.0%"
    assert_text "10.0%"
    assert_text "22.0%"
    assert_text "Updated terms with better advance"
  end

  test "moving deal through status workflow" do
    deal = deals(:negotiating_deal)

    visit deal_path(deal)

    # Verify initial status is negotiating
    within "[data-testid='deal-status']" do
      assert_text "negotiating"
    end

    # Go to edit page
    click_link "Edit"

    assert_selector "h1", text: "Edit Deal"

    # Change status to pending_contract
    select "Pending contract", from: "Status"

    # Set contract date
    page.execute_script("document.querySelector('input[name=\"deal[contract_date]\"]').value = '2026-01-20'")

    click_button "Update Deal"

    # Should redirect to show page with updated status
    assert_text "Deal was successfully updated"

    # Verify the status has been updated
    within "[data-testid='deal-status']" do
      assert_text "pending_contract"
    end

    # The deal progress section should reflect the new status
    assert_selector ".bg-blue-600", text: "2"  # Step 2 should be highlighted
  end
end
