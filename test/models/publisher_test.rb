require "test_helper"

class PublisherTest < ActiveSupport::TestCase
  # Validation tests
  test "requires name" do
    publisher = Publisher.new(name: nil)
    assert_not publisher.valid?
    assert_includes publisher.errors[:name], "can't be blank"
  end

  test "validates contact email format when provided" do
    publisher = Publisher.new(
      name: "Test Publisher",
      contact_email: "invalid-email"
    )
    assert_not publisher.valid?
    assert_includes publisher.errors[:contact_email], "is invalid"
  end

  test "allows valid contact email format" do
    publisher = Publisher.new(
      name: "Test Publisher",
      contact_email: "contact@publisher.com"
    )
    assert publisher.valid?
  end

  test "allows blank contact email" do
    publisher = Publisher.new(
      name: "Test Publisher",
      contact_email: nil
    )
    assert publisher.valid?
  end

  test "validates website format when provided" do
    publisher = Publisher.new(
      name: "Test Publisher",
      website: "not-a-valid-url"
    )
    assert_not publisher.valid?
    assert_includes publisher.errors[:website], "is invalid"
  end

  test "allows valid website format" do
    publisher = Publisher.new(
      name: "Test Publisher",
      website: "https://www.publisher.com"
    )
    assert publisher.valid?
  end

  test "allows blank website" do
    publisher = Publisher.new(
      name: "Test Publisher",
      website: nil
    )
    assert publisher.valid?
  end

  test "validates size is a known value" do
    publisher = Publisher.new(
      name: "Test Publisher",
      size: "unknown_size"
    )
    assert_not publisher.valid?
    assert_includes publisher.errors[:size], "is not included in the list"
  end

  test "allows valid size values" do
    %w[big_five major mid_size small indie].each do |valid_size|
      publisher = Publisher.new(
        name: "Test Publisher",
        size: valid_size
      )
      assert publisher.valid?, "Expected size '#{valid_size}' to be valid"
    end
  end

  test "allows blank size" do
    publisher = Publisher.new(
      name: "Test Publisher",
      size: nil
    )
    assert publisher.valid?
  end

  test "validates status is a known value" do
    publisher = Publisher.new(
      name: "Test Publisher",
      status: "unknown_status"
    )
    assert_not publisher.valid?
    assert_includes publisher.errors[:status], "is not included in the list"
  end

  test "allows valid status values" do
    %w[active inactive].each do |valid_status|
      publisher = Publisher.new(
        name: "Test Publisher",
        status: valid_status
      )
      assert publisher.valid?, "Expected status '#{valid_status}' to be valid"
    end
  end

  # Instance method tests
  test "returns full address formatted" do
    publisher = Publisher.new(
      name: "Test Publisher",
      address_line1: "123 Main Street",
      address_line2: "Suite 100",
      city: "New York",
      state: "NY",
      postal_code: "10001",
      country: "USA"
    )
    expected = "123 Main Street\nSuite 100\nNew York, NY 10001\nUSA"
    assert_equal expected, publisher.full_address
  end

  test "returns full address without address_line2 when blank" do
    publisher = Publisher.new(
      name: "Test Publisher",
      address_line1: "123 Main Street",
      city: "New York",
      state: "NY",
      postal_code: "10001",
      country: "USA"
    )
    expected = "123 Main Street\nNew York, NY 10001\nUSA"
    assert_equal expected, publisher.full_address
  end

  test "returns nil full address when address is empty" do
    publisher = Publisher.new(name: "Test Publisher")
    assert_nil publisher.full_address
  end

  test "identifies big five publishers" do
    big_five = publishers(:penguin_random_house)
    indie = publishers(:indie_press)

    assert big_five.big_five?
    assert_not indie.big_five?
  end

  test "returns display name with imprint when present" do
    publisher = Publisher.new(
      name: "Penguin Random House",
      imprint: "Penguin Books"
    )
    assert_equal "Penguin Random House (Penguin Books)", publisher.display_name
  end

  test "returns display name without imprint when not present" do
    publisher = Publisher.new(
      name: "Chronicle Books",
      imprint: nil
    )
    assert_equal "Chronicle Books", publisher.display_name
  end

  # Scope tests
  test "scopes active publishers" do
    active_publishers = Publisher.active

    assert_includes active_publishers, publishers(:penguin_random_house)
    assert_includes active_publishers, publishers(:harpercollins)
    assert_not_includes active_publishers, publishers(:defunct_publishing)
  end

  test "scopes publishers by size category" do
    big_five = Publisher.by_size("big_five")

    assert_includes big_five, publishers(:penguin_random_house)
    assert_includes big_five, publishers(:harpercollins)
    assert_includes big_five, publishers(:simon_schuster)
    assert_includes big_five, publishers(:hachette)
    assert_includes big_five, publishers(:macmillan)
    assert_not_includes big_five, publishers(:scholastic)
    assert_not_includes big_five, publishers(:indie_press)
  end

  test "searches publishers by name" do
    results = Publisher.search("Penguin")
    assert_includes results, publishers(:penguin_random_house)
    assert_not_includes results, publishers(:harpercollins)

    # Should also search partial matches
    results = Publisher.search("Random")
    assert_includes results, publishers(:penguin_random_house)
  end

  test "search is case insensitive" do
    results = Publisher.search("penguin")
    assert_includes results, publishers(:penguin_random_house)

    results = Publisher.search("HARPERCOLLINS")
    assert_includes results, publishers(:harpercollins)
  end

  test "orders publishers alphabetically" do
    ordered = Publisher.alphabetical

    # Get all names in order
    names = ordered.pluck(:name)

    # Verify they are sorted
    assert_equal names.sort, names
  end
end
