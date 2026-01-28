require "application_system_test_case"

class AuthorsSystemTest < ApplicationSystemTestCase
  test "viewing the authors list" do
    visit authors_path

    assert_selector "h1", text: "Authors"

    # Verify authors from fixtures are displayed
    assert_text "Jane Austen"
    assert_text "Stephen King"
    assert_text "Agatha Christie"

    # Verify table structure
    assert_selector "table"
    assert_selector "[data-testid='author-row']", minimum: 3
  end

  test "searching for an author by name" do
    visit authors_path

    # Search for a specific author
    fill_in "search", with: "Jane"
    click_button "Search"

    # Should find Jane Austen
    assert_text "Jane Austen"

    # Should not show other authors
    assert_no_text "Stephen King"
    assert_no_text "Agatha Christie"
  end

  test "filtering authors by status" do
    visit authors_path

    # Click on inactive filter
    click_link "Inactive", match: :first

    # Should show inactive author
    assert_text "Retired Novelist"

    # Should not show active authors
    assert_no_text "Jane Austen"
    assert_no_text "Stephen King"

    # Filter by deceased
    click_link "Deceased", match: :first

    # Should show deceased author
    assert_text "Classic Writer"

    # Should not show inactive or active authors
    assert_no_text "Retired Novelist"
    assert_no_text "Jane Austen"
  end

  test "creating a new author" do
    visit authors_path

    click_link "New Author"

    assert_selector "h1", text: "New Author"

    fill_in "First Name", with: "Ernest"
    fill_in "Last Name", with: "Hemingway"
    fill_in "Email", with: "ernest.hemingway@example.com"
    fill_in "Phone", with: "555-0199"
    fill_in "Website", with: "https://hemingway.example.com"
    fill_in "Genre Focus", with: "Literary Fiction"
    fill_in "Bio", with: "American novelist known for his economical style."
    fill_in "Notes", with: "Nobel Prize winner"

    click_button "Create Author"

    # Should redirect to author show page
    assert_text "Author was successfully created"
    assert_text "Ernest Hemingway"
    assert_text "ernest.hemingway@example.com"
  end

  test "viewing author details" do
    author = authors(:jane_austen)

    visit author_path(author)

    # Header information
    assert_selector "h1", text: "Jane Austen"
    assert_text "JA" # Initials
    assert_text "Active"

    # Contact details
    assert_text "jane.austen@example.com"
    assert_text "555-0101"
    assert_text "https://janeausten.example.com"

    # Author information
    assert_text "Romance"
    assert_text "English novelist known for her romantic fiction."
    assert_text "Classic literature author"

    # Navigation
    assert_link "Edit"
    assert_link "Back to Authors"
  end

  test "editing an author inline" do
    author = authors(:jane_austen)

    visit author_path(author)

    # Click edit button on show page
    click_link "Edit"

    assert_selector "h1", text: "Edit Author"

    # Update the bio
    fill_in "Bio", with: "Updated bio: English novelist known for romantic fiction and social commentary."
    click_button "Update Author"

    # Should redirect back to show page with updated content
    assert_text "Author was successfully updated"
    assert_text "Updated bio: English novelist known for romantic fiction and social commentary."
  end

  test "changing author status" do
    author = authors(:jane_austen)

    visit edit_author_path(author)

    # Change status from active to inactive
    select "Inactive", from: "Status"
    click_button "Update Author"

    # Verify status change
    assert_text "Author was successfully updated"

    # The status badge should now show inactive
    within "[data-testid='author-status']" do
      assert_text "inactive"
    end
  end

  test "navigating between author tabs" do
    author = authors(:jane_austen)

    visit author_path(author)

    # Should have tab navigation
    within "[data-testid='author-tabs']" do
      assert_link "Books"
      assert_link "Deals"
      assert_link "Agents"
    end

    # Books tab should be visible by default
    assert_selector "[data-testid='books-tab-content']", visible: true
    assert_selector "[data-testid='deals-tab-content']", visible: false
    assert_selector "[data-testid='agents-tab-content']", visible: false

    # Click on Deals tab
    within "[data-testid='author-tabs']" do
      click_link "Deals"
    end
    assert_selector "[data-testid='deals-tab-content']", visible: true
    assert_selector "[data-testid='books-tab-content']", visible: false

    # Click on Agents tab
    within "[data-testid='author-tabs']" do
      click_link "Agents"
    end
    assert_selector "[data-testid='agents-tab-content']", visible: true
    assert_selector "[data-testid='deals-tab-content']", visible: false

    # Click back to Books tab
    within "[data-testid='author-tabs']" do
      click_link "Books"
    end
    assert_selector "[data-testid='books-tab-content']", visible: true
    assert_selector "[data-testid='agents-tab-content']", visible: false
  end
end
