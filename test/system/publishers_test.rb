require "application_system_test_case"

class PublishersSystemTest < ApplicationSystemTestCase
  test "viewing the publishers list" do
    visit publishers_path

    assert_selector "h1", text: "Publishers"

    # Verify publishers from fixtures are displayed
    assert_text "Penguin Random House"
    assert_text "HarperCollins"
    assert_text "Simon & Schuster"

    # Verify table structure
    assert_selector "table"
    assert_selector "[data-testid='publisher-row']", minimum: 3
  end

  test "filtering publishers by size" do
    visit publishers_path

    # Click on Big Five filter
    click_link "Big Five"

    # Should show big five publishers
    assert_text "Penguin Random House"
    assert_text "HarperCollins"
    assert_text "Simon & Schuster"

    # Should not show indie or small publishers
    assert_no_text "Indie Literary Press"
    assert_no_text "Graywolf Press"

    # Filter by Indie
    click_link "Indie"

    # Should show indie publisher
    assert_text "Indie Literary Press"

    # Should not show big five publishers
    assert_no_text "Penguin Random House"
    assert_no_text "HarperCollins"
  end

  test "creating a new publisher" do
    visit publishers_path

    click_link "New Publisher"

    assert_selector "h1", text: "New Publisher"

    # Fill in basic information
    fill_in "Publisher Name", with: "New Test Publishing"
    fill_in "Imprint", with: "Test Imprint"
    fill_in "Website", with: "https://newtestpublishing.com"
    select "Mid Size", from: "Size"
    select "Active", from: "Status"

    # Fill in contact information
    fill_in "Contact Name", with: "Jane Smith"
    fill_in "Contact Email", with: "jane@newtestpublishing.com"
    fill_in "Contact Phone", with: "555-0199"
    fill_in "Main Phone", with: "555-0100"

    # Fill in address
    fill_in "Address Line 1", with: "123 Publisher Lane"
    fill_in "City", with: "New York"
    fill_in "State/Province", with: "NY"
    fill_in "Postal Code", with: "10001"
    fill_in "Country", with: "USA"

    # Fill in notes
    fill_in "Notes", with: "A brand new publisher for testing"

    click_button "Create Publisher"

    # Should redirect to publisher show page
    assert_text "Publisher was successfully created"
    assert_text "New Test Publishing (Test Imprint)"
    assert_text "jane@newtestpublishing.com"
  end

  test "viewing publisher details with deals" do
    publisher = publishers(:penguin_random_house)

    visit publisher_path(publisher)

    # Header information
    assert_selector "h1", text: "Penguin Random House (Penguin Books)"
    assert_text "PE" # Initials
    assert_text "Active"
    assert_text "Big Five"

    # Contact details
    assert_text "John Smith"
    assert_text "john.smith@penguinrandomhouse.com"
    assert_text "212-782-9001"

    # Address
    assert_text "1745 Broadway"
    assert_text "New York"

    # Notes
    assert_text "Largest publisher in the world by revenue"

    # Navigation
    assert_link "Edit"
    assert_link "Back to Publishers"

    # Should have tab navigation with Books and Deals
    within "[data-testid='publisher-tabs']" do
      assert_link "Books"
      assert_link "Deals"
    end

    # Books tab should be visible by default
    assert_selector "[data-testid='books-tab-content']", visible: true
    assert_selector "[data-testid='deals-tab-content']", visible: false

    # Click on Deals tab
    within "[data-testid='publisher-tabs']" do
      click_link "Deals"
    end

    # Deals tab should now be visible (even if empty)
    assert_selector "[data-testid='deals-tab-content']", visible: true
    assert_selector "[data-testid='books-tab-content']", visible: false

    # Should show deals data (Penguin Random House has the Pride & Prejudice deal)
    assert_text "Pride and Prejudice"
  end

  test "editing publisher contact information" do
    publisher = publishers(:penguin_random_house)

    visit publisher_path(publisher)

    # Click edit link on show page
    click_link "Edit", match: :first

    assert_selector "h1", text: "Edit Publisher"

    # Update contact information
    fill_in "Contact Name", with: "Sarah Johnson"
    fill_in "Contact Email", with: "sarah.johnson@penguinrandomhouse.com"
    fill_in "Contact Phone", with: "212-782-9999"

    click_button "Update Publisher"

    # Should redirect back to show page with updated content
    assert_text "Publisher was successfully updated"
    assert_text "Sarah Johnson"

    # Verify the new contact email is displayed
    within "[data-testid='publisher-contact-email']" do
      assert_text "sarah.johnson@penguinrandomhouse.com"
    end
  end
end
