require "application_system_test_case"

class AgentsSystemTest < ApplicationSystemTestCase
  test "viewing the agents list" do
    visit agents_path

    assert_selector "h1", text: "Agents"

    # Verify agents from fixtures are displayed
    assert_text "Simon Lipskar"
    assert_text "Esther Newberg"
    assert_text "Molly Friedrich"

    # Verify table structure
    assert_selector "table"
    assert_selector "[data-testid='agent-row']", minimum: 3

    # Verify key columns are displayed
    assert_text "Writers House"
    assert_text "ICM Partners"
    assert_text "The Friedrich Agency"
  end

  test "viewing agents grouped by agency" do
    visit agents_path

    # Click on "Group by Agency" toggle
    click_link "Group by Agency"

    # Should show agency groups
    assert_selector "[data-testid='agency-group']", minimum: 3

    # Verify specific agencies are shown as group headers
    assert_text "Writers House"
    assert_text "ICM Partners"
    assert_text "The Friedrich Agency"

    # Verify agents appear under their agencies
    # ICM Partners should have multiple agents
    within "[data-testid='agency-group']", text: "ICM Partners" do
      assert_text "Esther Newberg"
      assert_text "Jennifer Joel"
    end

    # Click "List View" to go back to flat list
    click_link "List View"

    # Should no longer show agency groups
    assert_no_selector "[data-testid='agency-group']"
    assert_selector "table thead"
  end

  test "filtering agents by genre represented" do
    visit agents_path

    # Click on a genre filter (Crime Fiction is in the list)
    click_link "Crime Fiction"

    # Should show agent who represents Crime Fiction (mystery_agent)
    assert_text "Sarah Thompson"

    # Should not show romance-only agent
    assert_no_text "Emily Davis"

    # Clear filter
    click_link "Clear", match: :first

    # Should show all agents again
    assert_text "Emily Davis"
    assert_text "Sarah Thompson"

    # Now filter by Fantasy
    click_link "Fantasy"

    # Should show agent with Fantasy (simon_lipskar has "Literary Fiction, Science Fiction, Fantasy")
    assert_text "Simon Lipskar"

    # Should not show romance-only agent (she has "Romance, Women's Fiction")
    assert_no_text "Emily Davis"
  end

  test "creating a new agent" do
    visit agents_path

    click_link "New Agent"

    assert_selector "h1", text: "New Agent"

    # Fill in personal information
    fill_in "First Name", with: "John"
    fill_in "Last Name", with: "Smith"
    fill_in "Email", with: "john.smith@newagency.example.com"
    fill_in "Phone", with: "555-0199"

    # Fill in agency information
    fill_in "Agency Name", with: "New Literary Agency"
    fill_in "Agency Website", with: "https://newliterary.example.com"
    fill_in "Commission Rate (%)", with: "15"
    select "Active", from: "Status"

    # Fill in address
    fill_in "Address Line 1", with: "789 Agent Street"
    fill_in "City", with: "Boston"
    fill_in "State", with: "MA"
    fill_in "Postal Code", with: "02101"
    fill_in "Country", with: "USA"

    # Fill in professional details
    fill_in "Genres Represented", with: "Literary Fiction, Historical Fiction"
    fill_in "Notes", with: "New agent for testing"

    click_button "Create Agent"

    # Should redirect to agent show page
    assert_text "Agent was successfully created"
    assert_text "John Smith"
    assert_text "New Literary Agency"
    assert_text "john.smith@newagency.example.com"
  end

  test "viewing agent details with clients" do
    agent = agents(:simon_lipskar)

    visit agent_path(agent)

    # Header information
    assert_selector "h1", text: "Simon Lipskar"
    assert_text "SL" # Initials
    assert_text "Writers House"
    assert_text "Active"

    # Contact details
    assert_text "simon.lipskar@writershouse.example.com"
    assert_text "212-555-0101"
    assert_text "https://writershouse.com"

    # Commission rate
    assert_text "15.0%"

    # Genres represented
    assert_text "Literary Fiction"
    assert_text "Science Fiction"
    assert_text "Fantasy"

    # Address
    assert_text "21 West 26th Street"
    assert_text "New York"

    # Notes
    assert_text "Represents major authors including Brandon Sanderson"

    # Navigation
    assert_link "Edit"
    assert_link "Back to Agents"

    # Should have tab navigation with Authors and Deals
    within "[data-testid='agent-tabs']" do
      assert_link "Authors"
      assert_link "Deals"
    end

    # Authors tab should be visible by default
    assert_selector "[data-testid='authors-tab-content']", visible: true
    assert_selector "[data-testid='deals-tab-content']", visible: false

    # Click on Deals tab
    within "[data-testid='agent-tabs']" do
      click_link "Deals"
    end

    # Deals tab should now be visible (even if empty)
    assert_selector "[data-testid='deals-tab-content']", visible: true
    assert_selector "[data-testid='authors-tab-content']", visible: false

    # Should show empty state for deals
    assert_text "No deals yet"
  end

  test "editing agent commission rate" do
    agent = agents(:romance_agent)

    visit agent_path(agent)

    # Verify current commission rate
    assert_text "12.5%"

    # Click edit link on show page
    click_link "Edit"

    assert_selector "h1", text: "Edit Agent"

    # Update commission rate
    fill_in "Commission Rate (%)", with: "17.5"

    click_button "Update Agent"

    # Should redirect back to show page with updated content
    assert_text "Agent was successfully updated"
    assert_text "17.5%"
  end
end
