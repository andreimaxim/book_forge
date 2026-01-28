require "test_helper"

class ErrorHandlingTest < ActionDispatch::IntegrationTest
  test "displays 404 page for missing record" do
    get author_path(id: 999999)

    assert_response :not_found
    assert_select "h1", text: /not found/i
    assert_select "[data-testid='error-page']"
  end

  test "displays 404 page for missing book" do
    get book_path(id: 999999)

    assert_response :not_found
    assert_select "h1", text: /not found/i
  end

  test "displays 404 page for missing deal" do
    get deal_path(id: 999999)

    assert_response :not_found
    assert_select "h1", text: /not found/i
  end

  test "displays 404 page for missing publisher" do
    get publisher_path(id: 999999)

    assert_response :not_found
    assert_select "h1", text: /not found/i
  end

  test "displays 404 page for missing agent" do
    get agent_path(id: 999999)

    assert_response :not_found
    assert_select "h1", text: /not found/i
  end

  test "displays 404 page for missing prospect" do
    get prospect_path(id: 999999)

    assert_response :not_found
    assert_select "h1", text: /not found/i
  end

  test "displays 422 page for invalid form submission" do
    post authors_path, params: {
      author: { first_name: "", last_name: "", email: "bad" }
    }

    assert_response :unprocessable_entity
    # Inline validation errors should be displayed on the form
    assert_select ".text-red-600"
  end

  test "displays 500 page for server error" do
    # Simulate a server error by stubbing the model to raise a RuntimeError.
    # In test env, Rails will re-raise non-rescuable exceptions.
    # Our ErrorHandling concern rescues StandardError in non-local mode.
    # For testing, we stub ApplicationController to simulate production behavior.
    Author.stubs(:alphabetical).raises(RuntimeError, "Something went wrong")

    get authors_path

    assert_response :internal_server_error
    assert_select "h1", text: /something went wrong/i
    assert_select "[data-testid='error-page']"
  end

  test "logs errors appropriately" do
    # Ensure that when a record is not found, it is logged
    Rails.logger.expects(:warn).with(regexp_matches(/RecordNotFound.*Author/))

    get author_path(id: 999999)

    assert_response :not_found
  end

  test "handles stale record gracefully" do
    author = authors(:jane_austen)

    # Simulate a stale object error (optimistic locking conflict)
    Author.any_instance.stubs(:update).raises(
      ActiveRecord::StaleObjectError.new(author, "update")
    )

    patch author_path(author), params: {
      author: { first_name: "Updated" }
    }

    assert_response :conflict
    assert_select "[data-testid='error-page']"
    assert_select "h1", text: /modified/i
  end

  test "404 page includes link to home" do
    get author_path(id: 999999)

    assert_response :not_found
    assert_select "a[href='#{root_path}']", text: /home|back|dashboard/i
  end

  test "error pages use the application layout" do
    get author_path(id: 999999)

    assert_response :not_found
    # Should include navigation from the application layout
    assert_select "nav"
  end

  test "handles missing record when editing" do
    get edit_author_path(id: 999999)

    assert_response :not_found
    assert_select "h1", text: /not found/i
  end

  test "handles missing record when updating" do
    patch author_path(id: 999999), params: {
      author: { first_name: "Test" }
    }

    assert_response :not_found
  end

  test "handles missing record when deleting" do
    delete author_path(id: 999999)

    assert_response :not_found
  end
end
