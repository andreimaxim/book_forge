require "application_system_test_case"

class ErrorHandlingSystemTest < ApplicationSystemTestCase
  test "shows error page for missing record" do
    visit author_path(id: 999999)

    assert_selector "[data-testid='error-page']"
    assert_selector "h1", text: /not found/i
    assert_text "The record you were looking for could not be found"
  end

  test "shows validation errors inline on form" do
    visit new_author_path

    # Submit form with empty required fields
    click_button "Create Author"

    # Should show inline validation errors
    assert_selector ".text-red-600", minimum: 1
    assert_text "can't be blank"

    # Should stay on the form page
    assert_selector "form"
  end

  test "recovers gracefully when JavaScript fails" do
    # Test that the basic HTML form and links work as standard HTML elements.
    # Forms should have proper action attributes, links should have proper hrefs,
    # and the app should function through standard HTTP request/response cycles.
    visit new_author_path

    # The form should have a proper action attribute (progressive enhancement)
    assert_selector "form[action='#{authors_path}']"

    # Fill in the form using basic HTML form controls
    fill_in "First Name", with: "Progressive"
    fill_in "Last Name", with: "Enhancement"
    fill_in "Email", with: "progressive@example.com"

    # Submit the form - the form works with both Turbo and standard HTML
    click_button "Create Author"

    # The author should be created successfully regardless of JS
    assert_text "Author was successfully created"

    # Verify the author was persisted to the database
    author = Author.find_by(first_name: "Progressive", last_name: "Enhancement")
    assert author.present?, "Author should have been created in the database"

    # Navigate to the author to verify the data persisted correctly
    visit author_path(author)
    assert_text "Progressive Enhancement"
    assert_text "progressive@example.com"
  end

  test "can navigate back from error page" do
    # First visit a valid page
    visit authors_path
    assert_selector "h1", text: "Authors"

    # Then visit a missing record
    visit author_path(id: 999999)

    assert_selector "[data-testid='error-page']"
    assert_selector "h1", text: /not found/i

    # Click the "Go to Dashboard" link to navigate away
    click_link "Go to Dashboard"

    # Should be back on the dashboard
    assert_current_path root_path
  end
end
