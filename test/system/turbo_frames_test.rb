require "application_system_test_case"

class TurboFramesSystemTest < ApplicationSystemTestCase
  test "filtering list updates only the list frame" do
    visit authors_path

    # The authors list should be wrapped in a turbo frame
    assert_selector "turbo-frame#authors_list"
    assert_text "Jane Austen"
    assert_text "Stephen King"

    # Click a status filter link -- it should update only the list frame
    click_link "Inactive", match: :first

    # The page header should still be present (it is outside the frame)
    assert_selector "h1", text: "Authors"

    # Only inactive authors should be shown inside the frame
    within "turbo-frame#authors_list" do
      assert_text "Retired Novelist"
      assert_no_text "Jane Austen"
    end
  end

  test "inline edit opens form in place" do
    author = authors(:jane_austen)
    visit author_path(author)

    # The author details section should be wrapped in a turbo frame
    assert_selector "turbo-frame##{dom_id(author)}"
    assert_text "Jane Austen"

    # Click inline edit -- expect a form to appear inside the same frame
    within "turbo-frame##{dom_id(author)}" do
      click_link "Edit"
    end

    # The edit form should appear within the turbo frame
    within "turbo-frame##{dom_id(author)}" do
      assert_selector "form"
      assert_field "First Name", with: "Jane"
      assert_field "Last Name", with: "Austen"
    end
  end

  test "inline edit submit updates the item" do
    author = authors(:jane_austen)
    visit author_path(author)

    within "turbo-frame##{dom_id(author)}" do
      click_link "Edit"
    end

    # Fill and submit within the frame
    within "turbo-frame##{dom_id(author)}" do
      fill_in "Bio", with: "Updated bio for inline edit test."
      click_button "Update Author"
    end

    # After turbo stream replaces the frame, re-query the DOM for the updated frame
    assert_selector "turbo-frame##{dom_id(author)}"
    assert_text "Updated bio for inline edit test."
    assert_no_selector "turbo-frame##{dom_id(author)} form"
  end

  test "inline edit cancel restores original content" do
    author = authors(:jane_austen)
    visit author_path(author)

    within "turbo-frame##{dom_id(author)}" do
      click_link "Edit"
    end

    # The form should have a Cancel link
    within "turbo-frame##{dom_id(author)}" do
      assert_selector "form"
      click_link "Cancel"
    end

    # The original content should be restored
    assert_selector "turbo-frame##{dom_id(author)}"
    assert_text "Jane Austen"
    assert_no_selector "turbo-frame##{dom_id(author)} form"
  end

  test "modal opens without page navigation" do
    visit authors_path

    # Click the New Author button that opens a modal
    click_link "New Author"

    # A modal frame should appear
    assert_selector "turbo-frame#modal"
    assert_selector "[data-testid='modal-container']"
    assert_selector "h2", text: "New Author"

    # The page header should still be present (modal is an overlay)
    assert_selector "h1", text: "Authors"
  end

  test "modal form submission closes modal" do
    visit authors_path

    click_link "New Author"

    # Fill in the modal form
    within "[data-testid='modal-container']" do
      fill_in "First Name", with: "Modal"
      fill_in "Last Name", with: "Author"
      fill_in "Email", with: "modal.author@example.com"
      click_button "Create Author"
    end

    # The modal should close and the page should update
    assert_no_selector "[data-testid='modal-container']"
    assert_text "Author was successfully created"
  end

  test "modal can be closed with escape key" do
    visit authors_path

    click_link "New Author"

    # The modal should be open
    assert_selector "[data-testid='modal-container']"

    # Press escape key to close modal -- send to active element on the page
    find("body").send_keys(:escape)

    # The modal should be gone
    assert_no_selector "[data-testid='modal-container']"
  end

  private

  def dom_id(record)
    ActionView::RecordIdentifier.dom_id(record)
  end
end
