require "test_helper"

class UiHelperTest < ActionView::TestCase
  test "renders primary button with correct styling" do
    result = primary_button("Save")

    assert_match /<a[^>]*>Save<\/a>/, result
    assert_match /bg-blue-600/, result
    assert_match /text-white/, result
    assert_match /hover:bg-blue-700/, result
  end

  test "renders secondary button with correct styling" do
    result = secondary_button("Cancel")

    assert_match /<a[^>]*>Cancel<\/a>/, result
    assert_match /bg-white/, result
    assert_match /text-gray-700/, result
    assert_match /border-gray-300/, result
    assert_match /hover:bg-gray-50/, result
  end

  test "renders danger button with confirmation" do
    result = danger_button("Delete", confirm: "Are you sure?")

    assert_match /<a[^>]*>Delete<\/a>/, result
    assert_match /bg-red-600/, result
    assert_match /text-white/, result
    assert_match /hover:bg-red-700/, result
    assert_match /data-turbo-confirm="Are you sure\?"/, result
  end

  test "renders form field with label and error" do
    # Create a mock form builder
    mock_form = mock("form")
    mock_object = mock("object")
    errors = ActiveModel::Errors.new(mock_object)
    errors.add(:email, "can't be blank")

    mock_form.stubs(:object).returns(mock_object)
    mock_object.stubs(:errors).returns(errors)

    mock_form.stubs(:label).with(:email, "Email", has_key(:class)).returns('<label for="email">Email</label>'.html_safe)
    mock_form.stubs(:text_field).with(:email, has_key(:class)).returns('<input type="text" name="email" id="email" />'.html_safe)

    result = form_field(mock_form, :email)

    assert_match /<label[^>]*>Email<\/label>/, result
    assert_match /<input[^>]*type="text"/, result
    assert_match /can&#39;t be blank/, result  # HTML-escaped apostrophe
    assert_match /text-red-600/, result
  end

  test "renders card component with title and content" do
    result = card(title: "User Details") { "Card content here" }

    assert_match /<div[^>]*class="[^"]*bg-white[^"]*"/, result
    assert_match /<div[^>]*class="[^"]*rounded-lg[^"]*"/, result
    assert_match /<div[^>]*class="[^"]*shadow[^"]*"/, result
    assert_match /User Details/, result
    assert_match /Card content here/, result
  end

  test "renders empty state with icon and message" do
    result = empty_state(icon: "inbox", message: "No items found")

    assert_match /<div[^>]*class="[^"]*text-center[^"]*"/, result
    assert_match /No items found/, result
    assert_match /text-gray-400/, result  # Icon color
    assert_match /text-gray-500/, result  # Message color
  end

  test "renders badge with appropriate color for status" do
    # Test active status (green)
    active_result = badge("Active", status: :active)
    assert_match /<span[^>]*>Active<\/span>/, active_result
    assert_match /bg-green-100/, active_result
    assert_match /text-green-800/, active_result

    # Test inactive status (gray)
    inactive_result = badge("Inactive", status: :inactive)
    assert_match /bg-gray-100/, inactive_result
    assert_match /text-gray-800/, inactive_result

    # Test pending status (yellow)
    pending_result = badge("Pending", status: :pending)
    assert_match /bg-yellow-100/, pending_result
    assert_match /text-yellow-800/, pending_result

    # Test error/danger status (red)
    error_result = badge("Failed", status: :error)
    assert_match /bg-red-100/, error_result
    assert_match /text-red-800/, error_result
  end
end
