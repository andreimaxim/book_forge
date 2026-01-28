require "application_system_test_case"

class NotesSystemTest < ApplicationSystemTestCase
  test "adding a note to an author" do
    author = authors(:jane_austen)

    visit author_path(author)

    # Click on the Notes tab to reveal the notes section
    within "[data-testid='author-tabs']" do
      click_link "Notes"
    end

    assert_selector "[data-testid='notes-tab-content']", visible: true

    # Fill in and submit a new note
    within "[data-testid='notes-tab-content']" do
      fill_in "note_content", with: "This is a new note about Jane Austen's upcoming project."
      click_button "Add Note"
    end

    # The new note should appear in the notes list
    assert_text "This is a new note about Jane Austen's upcoming project."
  end

  test "adding a note to a deal" do
    deal = deals(:pride_and_prejudice_deal)

    visit deal_path(deal)

    # The Notes tab should be visible by default on the deal page
    assert_selector "[data-testid='deal-tabs']"
    assert_selector "[data-testid='notes-tab-content']", visible: true

    # Fill in and submit a new note
    within "[data-testid='notes-tab-content']" do
      fill_in "note_content", with: "Follow up on contract terms before Friday."
      click_button "Add Note"
    end

    # The new note should appear in the notes list
    assert_text "Follow up on contract terms before Friday."
  end

  test "editing an existing note" do
    author = authors(:jane_austen)
    note = notes(:author_regular_note)

    visit author_path(author)

    # Click on the Notes tab
    within "[data-testid='author-tabs']" do
      click_link "Notes"
    end

    assert_selector "[data-testid='notes-tab-content']", visible: true

    # Find the note and click Edit
    within "##{dom_id(note)}" do
      click_button "Edit"
    end

    # The edit form should appear inline
    within "##{dom_id(note)}" do
      fill_in "note_content", with: "Updated note content with new information."
      click_button "Save"
    end

    # The updated note content should be visible
    assert_text "Updated note content with new information."
    assert_no_text "Discussed new manuscript ideas over lunch"
  end

  test "deleting a note" do
    author = authors(:jane_austen)
    note = notes(:author_regular_note)

    visit author_path(author)

    # Click on the Notes tab
    within "[data-testid='author-tabs']" do
      click_link "Notes"
    end

    assert_selector "[data-testid='notes-tab-content']", visible: true

    # Verify the note exists (use plain text portion since markdown is rendered to HTML)
    assert_text "Discussed new manuscript ideas over lunch"

    # Find the note and click Delete, accepting the confirmation
    within "##{dom_id(note)}" do
      accept_confirm "Are you sure you want to delete this note?" do
        click_button "Delete"
      end
    end

    # The note should no longer appear on the page
    assert_no_text "Discussed new manuscript ideas over lunch"
  end

  test "pinning a note" do
    author = authors(:jane_austen)
    note = notes(:author_regular_note)

    visit author_path(author)

    # Click on the Notes tab
    within "[data-testid='author-tabs']" do
      click_link "Notes"
    end

    assert_selector "[data-testid='notes-tab-content']", visible: true

    # The note should not currently be pinned
    within "##{dom_id(note)}" do
      assert_no_selector "[data-testid='note-pinned-badge']"
    end

    # Pin the note
    within "##{dom_id(note)}" do
      click_button "Pin"
    end

    # The note should now show the Pinned badge
    within "##{dom_id(note)}" do
      assert_selector "[data-testid='note-pinned-badge']", text: "Pinned"
    end
  end

  test "viewing markdown formatted note" do
    author = authors(:jane_austen)

    visit author_path(author)

    # Click on the Notes tab
    within "[data-testid='author-tabs']" do
      click_link "Notes"
    end

    assert_selector "[data-testid='notes-tab-content']", visible: true

    # Add a note with markdown formatting
    within "[data-testid='notes-tab-content']" do
      fill_in "note_content", with: "This has **bold text** and _italic text_ for emphasis."
      click_button "Add Note"
    end

    # The rendered note should contain HTML formatted content
    assert_selector "strong", text: "bold text"
    assert_selector "em", text: "italic text"
  end

  private

  def dom_id(record)
    ActionView::RecordIdentifier.dom_id(record)
  end
end
