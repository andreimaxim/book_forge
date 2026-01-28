require "application_system_test_case"

class DesignSystemTest < ApplicationSystemTestCase
  test "flash messages appear and can be dismissed" do
    visit design_system_test_flash_path

    # Flash notice should be visible
    assert_selector "[data-testid='flash-notice']", text: "This is a test notice"

    # Click the dismiss button
    within("[data-testid='flash-notice']") do
      find("[data-testid='flash-dismiss']").click
    end

    # Flash should be removed from the page
    assert_no_selector "[data-testid='flash-notice']"
  end

  test "form validation errors display inline" do
    visit design_system_test_form_path

    # Submit form with invalid data (empty fields)
    click_button "Submit"

    # Validation errors should appear inline next to each field
    assert_selector "[data-testid='error-name']", text: "can't be blank"
    assert_selector "[data-testid='error-email']", text: "can't be blank"

    # Form should still be visible (not redirected)
    assert_selector "form"
  end

  test "buttons show loading state when clicked" do
    visit design_system_test_button_path

    # Find the button and verify initial state
    button = find("[data-testid='loading-button']")
    assert_equal "Perform Action", button.value

    # Click the button
    button.click

    # Button should show loading state (disabled and value changed)
    assert_selector "[data-testid='loading-button'][disabled]"
    assert_equal "Loading...", find("[data-testid='loading-button']").value
  end
end
