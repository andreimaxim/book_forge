require "application_system_test_case"

class StimulusControllersSystemTest < ApplicationSystemTestCase
  # ── Form Validation Controller ──────────────────────────────────────────────

  test "form shows validation errors before submit" do
    visit stimulus_test_form_validation_path

    # Try to submit the form without filling in required fields
    click_button "Save"

    # Client-side validation messages should appear before the form is submitted
    assert_selector "[data-testid='validation-error-name']", text: "is required"
    assert_selector "[data-testid='validation-error-email']", text: "is required"

    # The form should NOT have been submitted (we're still on the same page)
    assert_no_selector "[data-testid='form-submitted']"
  end

  # ── Auto-Save Controller ────────────────────────────────────────────────────

  test "form auto-saves draft after typing stops" do
    visit stimulus_test_auto_save_path

    # Type into the auto-save field
    fill_in "Content", with: "Auto-saved draft content"

    # Wait for the debounce period to elapse and the auto-save indicator to appear
    assert_selector "[data-testid='auto-save-status']", text: "Saved", wait: 3
  end

  # ── Dropdown Controller ─────────────────────────────────────────────────────

  test "dropdown opens on click" do
    visit stimulus_test_dropdown_path

    # The dropdown menu should be hidden initially
    assert_no_selector "[data-testid='dropdown-menu']", visible: :visible

    # Click the dropdown toggle button
    find("[data-testid='dropdown-toggle']").click

    # The dropdown menu should now be visible
    assert_selector "[data-testid='dropdown-menu']", visible: :visible
    assert_selector "[data-testid='dropdown-item']", minimum: 1
  end

  test "dropdown closes when clicking outside" do
    visit stimulus_test_dropdown_path

    # Open the dropdown
    find("[data-testid='dropdown-toggle']").click
    assert_selector "[data-testid='dropdown-menu']", visible: :visible

    # Click outside the dropdown
    find("[data-testid='outside-area']").click

    # The dropdown should be closed
    assert_no_selector "[data-testid='dropdown-menu']", visible: :visible
  end

  test "dropdown closes on escape key" do
    visit stimulus_test_dropdown_path

    # Open the dropdown
    find("[data-testid='dropdown-toggle']").click
    assert_selector "[data-testid='dropdown-menu']", visible: :visible

    # Press Escape
    find("body").send_keys(:escape)

    # The dropdown should be closed
    assert_no_selector "[data-testid='dropdown-menu']", visible: :visible
  end

  # ── Clipboard Controller ────────────────────────────────────────────────────

  test "copy button copies text to clipboard" do
    visit stimulus_test_clipboard_path

    # Verify the copy source text is present
    assert_selector "[data-testid='copy-source']", text: "Text to copy"

    # Click the copy button
    find("[data-testid='copy-button']").click

    # The button should show a "Copied!" confirmation
    assert_selector "[data-testid='copy-button']", text: "Copied!"
  end

  # ── Character Count Controller ──────────────────────────────────────────────

  test "character count updates while typing" do
    visit stimulus_test_character_count_path

    # The counter should show 0 initially
    assert_selector "[data-testid='char-count']", text: "0 / 200"

    # Type some text
    fill_in "Description", with: "Hello World"

    # The counter should update
    assert_selector "[data-testid='char-count']", text: "11 / 200"
  end

  test "character count shows warning near limit" do
    visit stimulus_test_character_count_path

    # Type text close to the limit (200 chars)
    long_text = "x" * 185
    fill_in "Description", with: long_text

    # The counter should have a warning style
    assert_selector "[data-testid='char-count'].text-amber-600", text: "185 / 200"
  end

  # ── Filter Controller ───────────────────────────────────────────────────────

  test "filter form submits automatically on change" do
    visit stimulus_test_filter_path

    # Select a filter option
    select "Fiction", from: "Genre"

    # The results should update automatically (via form auto-submit)
    assert_selector "[data-testid='filter-results']", text: "Fiction"
  end

  # ── Sortable Controller ─────────────────────────────────────────────────────

  test "list items can be reordered by dragging" do
    visit stimulus_test_sortable_path

    # Verify initial order
    items = all("[data-testid='sortable-item']")
    assert_equal "Item 1", items[0].text.strip
    assert_equal "Item 2", items[1].text.strip
    assert_equal "Item 3", items[2].text.strip

    # Drag item 1 below item 2
    source = items[0]
    target = items[2]
    source.drag_to(target)

    # Verify the order has changed -- item 1 should have moved down
    reordered = all("[data-testid='sortable-item']")
    # After drag, item 1 should no longer be first
    assert_not_equal "Item 1", reordered[0].text.strip,
      "Expected the order to change after drag"
  end

  # ── Toast Controller ────────────────────────────────────────────────────────

  test "toast notification appears and auto-dismisses" do
    visit stimulus_test_toast_path

    # Trigger a toast notification
    click_button "Show Toast"

    # The toast should appear
    assert_selector "[data-testid='toast']", text: "Operation successful"

    # Wait for the toast to auto-dismiss (3 seconds + animation)
    assert_no_selector "[data-testid='toast']", wait: 5
  end

  test "toast can be dismissed manually" do
    visit stimulus_test_toast_path

    # Trigger a toast notification
    click_button "Show Toast"

    # The toast should appear
    assert_selector "[data-testid='toast']", text: "Operation successful"

    # Click the dismiss button on the toast
    within("[data-testid='toast']") do
      find("[data-testid='toast-dismiss']").click
    end

    # The toast should be gone
    assert_no_selector "[data-testid='toast']"
  end
end
