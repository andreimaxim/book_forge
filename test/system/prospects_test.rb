require "application_system_test_case"

class ProspectsSystemTest < ApplicationSystemTestCase
  test "viewing the prospects list" do
    visit prospects_path

    assert_selector "h1", text: "Prospects"

    # Verify prospects from fixtures are displayed
    assert_text "Sarah Johnson"  # new_prospect
    assert_text "Michael Chen"   # contacted_prospect
    assert_text "Emily Rodriguez" # evaluating_prospect
    assert_text "David Kim"      # negotiating_prospect

    # Verify table structure
    assert_selector "table"
    assert_selector "[data-testid='prospect-row']", minimum: 4

    # Verify table columns are visible (headers are uppercase)
    assert_selector "th", text: "NAME"
    assert_selector "th", text: "PROJECT"
    assert_selector "th", text: "SOURCE"
    assert_selector "th", text: "STAGE"
    assert_selector "th", text: "AGENT"
    assert_selector "th", text: "FOLLOW UP"
  end

  test "viewing prospects in pipeline view" do
    visit prospects_path

    # Click on Pipeline View button
    click_link "Pipeline View"

    # Should show pipeline/kanban view with stage columns
    assert_selector "[data-testid='pipeline-stage-new']"
    assert_selector "[data-testid='pipeline-stage-contacted']"
    assert_selector "[data-testid='pipeline-stage-evaluating']"
    assert_selector "[data-testid='pipeline-stage-negotiating']"

    # Verify stage headers
    assert_text "New"
    assert_text "Contacted"
    assert_text "Evaluating"
    assert_text "Negotiating"

    # Prospects should be in their respective stages
    within "[data-testid='pipeline-stage-new']" do
      assert_text "Sarah Johnson"  # new_prospect
    end

    within "[data-testid='pipeline-stage-contacted']" do
      assert_text "Michael Chen"   # contacted_prospect
    end

    within "[data-testid='pipeline-stage-evaluating']" do
      assert_text "Emily Rodriguez" # evaluating_prospect
    end

    within "[data-testid='pipeline-stage-negotiating']" do
      assert_text "David Kim"      # negotiating_prospect
    end

    # Should have a button to go back to list view
    assert_link "List View"
  end

  test "moving prospect between stages" do
    prospect = prospects(:new_prospect)  # Sarah Johnson - in "new" stage

    visit edit_prospect_path(prospect)

    # Verify current stage
    assert_select "Stage", selected: "New"

    # Change stage to contacted
    select "Contacted", from: "Stage"
    click_button "Update Prospect"

    # Should redirect to show page with updated stage
    assert_text "Prospect was successfully updated"

    # Verify the stage changed
    within "[data-testid='prospect-stage']" do
      assert_text "contacted"
    end
  end

  test "creating a new prospect" do
    visit prospects_path

    click_link "New Prospect"

    assert_selector "h1", text: "New Prospect"

    # Fill in contact information
    fill_in "First Name", with: "John"
    fill_in "Last Name", with: "Smith"
    fill_in "Email", with: "john.smith@example.com"
    fill_in "Phone", with: "555-0300"

    # Fill in pipeline status
    select "Referral", from: "Source"
    select "New", from: "Stage"
    fill_in "Genre Interest", with: "Fantasy"

    # Fill in project information
    fill_in "Project Title", with: "The Dragon's Path"
    fill_in "Project Description", with: "An epic fantasy novel about a young mage."
    fill_in "Estimated Word Count", with: "100000"

    # Fill in additional information
    fill_in "Notes", with: "Promising new author"

    click_button "Create Prospect"

    # Should redirect to prospect show page
    assert_text "Prospect was successfully created"
    assert_text "John Smith"
    assert_text "john.smith@example.com"
    assert_text "The Dragon's Path"
    assert_text "Fantasy"
  end

  test "viewing prospect details" do
    prospect = prospects(:negotiating_prospect)  # David Kim

    visit prospect_path(prospect)

    # Header information
    assert_selector "h1", text: "David Kim"
    assert_text "DK" # Initials
    assert_text "Code Red"  # Project title

    # Stage badge
    assert_text "Negotiating"

    # Contact details
    assert_text "david.kim@example.com"
    assert_text "555-0204"

    # Source
    assert_text "Website"

    # Assigned Agent
    assert_text "Jennifer Joel"

    # Genre Interest
    assert_text "Thriller"

    # Project details
    assert_text "techno-thriller about a cybersecurity expert"

    # Word count
    assert_text "90,000"

    # Notes
    assert_text "Excellent manuscript"

    # Navigation
    assert_link "Edit"
    assert_link "Back to Prospects"

    # Convert button should be visible for negotiating prospects
    assert_button "Convert to Author"
  end

  test "assigning an agent to prospect" do
    prospect = prospects(:unassigned_prospect)  # Christopher Lee - no agent assigned

    visit prospect_path(prospect)

    # Verify currently unassigned
    assert_text "Unassigned"

    # Go to edit page
    click_link "Edit"

    # Assign an agent
    select "Simon Lipskar", from: "Assigned Agent"
    click_button "Update Prospect"

    # Should redirect to show page with assigned agent
    assert_text "Prospect was successfully updated"
    assert_link "Simon Lipskar"
  end

  test "setting follow up date" do
    prospect = prospects(:new_prospect)  # Sarah Johnson - no follow up date

    visit edit_prospect_path(prospect)

    # Set follow up date to a week from now
    follow_up_date = 1.week.from_now.to_date

    # Use execute_script to set the date value directly for date input
    page.execute_script("document.querySelector('input[name=\"prospect[follow_up_date]\"]').value = '#{follow_up_date.strftime('%Y-%m-%d')}'")
    click_button "Update Prospect"

    # Should redirect to show page with follow up date
    assert_text "Prospect was successfully updated"
    assert_text follow_up_date.strftime("%B %d, %Y")
  end

  test "converting prospect to author" do
    prospect = prospects(:negotiating_prospect)  # David Kim - in negotiating stage

    visit prospect_path(prospect)

    # Verify convert button is present
    assert_button "Convert to Author"

    # Click the convert button
    click_button "Convert to Author"

    # Should redirect to the new author page
    assert_text "Prospect was successfully converted to author"
    assert_current_path author_path(Author.last)

    # Verify the author was created with the prospect's information
    assert_text "David Kim"
    assert_text "david.kim@example.com"

    # Verify the author notes include reference to the original prospect
    assert_text "Converted from prospect"
    assert_text "Code Red"  # Project title should be in notes
  end
end
