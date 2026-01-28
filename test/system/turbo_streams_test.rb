require "application_system_test_case"

class TurboStreamsSystemTest < ApplicationSystemTestCase
  test "creating record appends to list" do
    visit authors_path

    # Count current authors in the list
    initial_count = all("[data-testid='author-row']").count

    # Open modal and create a new author
    click_link "New Author"

    within "[data-testid='modal-container']" do
      fill_in "First Name", with: "Turbo"
      fill_in "Last Name", with: "Stream"
      fill_in "Email", with: "turbo.stream@example.com"
      click_button "Create Author"
    end

    # The new author should appear in the list without a full page reload
    assert_selector "[data-testid='author-row']", count: initial_count + 1
    assert_text "Turbo Stream"
  end

  test "updating record replaces in list" do
    author = authors(:jane_austen)

    # Visit the show page and edit inline
    visit author_path(author)

    frame_id = dom_id(author)

    within "turbo-frame##{frame_id}" do
      click_link "Edit"
    end

    within "turbo-frame##{frame_id}" do
      fill_in "Bio", with: "This is a turbo stream updated bio."
      click_button "Update Author"
    end

    # After turbo stream replacement, the updated content should appear
    # The turbo frame should show the detail view, not the form
    assert_selector "turbo-frame##{frame_id}"
    assert_text "This is a turbo stream updated bio."
    assert_no_selector "turbo-frame##{frame_id} form"
  end

  test "deleting record removes from list" do
    author = authors(:author_without_books)
    visit authors_path

    # Verify the author is listed
    assert_text "Deletable Author"
    initial_count = all("[data-testid='author-row']").count

    # Delete the author using turbo stream
    accept_confirm do
      within "##{dom_id(author)}" do
        click_link "Delete"
      end
    end

    # The author should be removed from the list without a full page reload
    assert_no_text "Deletable Author"
    assert_selector "[data-testid='author-row']", count: initial_count - 1
  end

  test "flash message appears and auto-dismisses" do
    visit authors_path

    click_link "New Author"

    within "[data-testid='modal-container']" do
      fill_in "First Name", with: "Flash"
      fill_in "Last Name", with: "Test"
      fill_in "Email", with: "flash.test@example.com"
      click_button "Create Author"
    end

    # Flash message should appear
    assert_selector "[data-testid='flash-notice']", text: "Author was successfully created"

    # Flash message should auto-dismiss after a few seconds
    assert_no_selector "[data-testid='flash-notice']", wait: 6
  end

  test "form errors display without page reload" do
    visit authors_path

    click_link "New Author"

    within "[data-testid='modal-container']" do
      # Submit without required fields
      fill_in "First Name", with: ""
      fill_in "Last Name", with: ""
      click_button "Create Author"
    end

    # Errors should appear within the modal without page reload
    assert_selector "[data-testid='modal-container']"
    assert_text "can't be blank"
    assert_selector "h1", text: "Authors"
  end

  private

  def dom_id(record)
    ActionView::RecordIdentifier.dom_id(record)
  end
end
