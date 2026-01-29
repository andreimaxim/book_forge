require "test_helper"

class AuthorTest < ActiveSupport::TestCase
  # Validation tests
  test "requires first name" do
    author = Author.new(first_name: nil, last_name: "Doe")
    assert_not author.valid?
    assert_includes author.errors[:first_name], "can't be blank"
  end

  test "requires last name" do
    author = Author.new(first_name: "John", last_name: nil)
    assert_not author.valid?
    assert_includes author.errors[:last_name], "can't be blank"
  end

  test "validates email format when provided" do
    author = Author.new(
      first_name: "John",
      last_name: "Doe",
      email: "invalid-email"
    )
    assert_not author.valid?
    assert_includes author.errors[:email], "is invalid"
  end

  test "allows valid email format" do
    author = Author.new(
      first_name: "John",
      last_name: "Doe",
      email: "john.doe@example.com"
    )
    assert author.valid?
  end

  test "allows blank email" do
    author = Author.new(
      first_name: "John",
      last_name: "Doe",
      email: nil
    )
    assert author.valid?
  end

  test "validates email uniqueness when provided" do
    existing_author = authors(:jane_austen)
    author = Author.new(
      first_name: "Another",
      last_name: "Jane",
      email: existing_author.email
    )
    assert_not author.valid?
    assert_includes author.errors[:email], "has already been taken"
  end

  test "allows multiple authors with blank email" do
    author1 = Author.create!(first_name: "First", last_name: "Author", email: nil)
    author2 = Author.new(first_name: "Second", last_name: "Author", email: nil)
    assert author2.valid?
  end

  test "validates website format when provided" do
    author = Author.new(
      first_name: "John",
      last_name: "Doe",
      website: "not-a-valid-url"
    )
    assert_not author.valid?
    assert_includes author.errors[:website], "is invalid"
  end

  test "allows valid website format" do
    author = Author.new(
      first_name: "John",
      last_name: "Doe",
      website: "https://example.com"
    )
    assert author.valid?
  end

  test "allows blank website" do
    author = Author.new(
      first_name: "John",
      last_name: "Doe",
      website: nil
    )
    assert author.valid?
  end

  test "raises error for invalid status value" do
    assert_raises(ArgumentError) do
      Author.new(
        first_name: "John",
        last_name: "Doe",
        status: "unknown_status"
      )
    end
  end

  test "allows valid status values" do
    %w[active inactive deceased].each do |valid_status|
      author = Author.new(
        first_name: "John",
        last_name: "Doe",
        status: valid_status
      )
      assert author.valid?, "Expected status '#{valid_status}' to be valid"
    end
  end

  # Instance method tests
  test "returns full name combining first and last name" do
    author = Author.new(first_name: "Jane", last_name: "Austen")
    assert_equal "Jane Austen", author.full_name
  end

  test "returns initials from first and last name" do
    author = Author.new(first_name: "Jane", last_name: "Austen")
    assert_equal "JA", author.initials
  end

  # Scope tests
  test "scopes active authors" do
    active_authors = Author.active

    assert_includes active_authors, authors(:jane_austen)
    assert_includes active_authors, authors(:stephen_king)
    assert_not_includes active_authors, authors(:inactive_author)
    assert_not_includes active_authors, authors(:deceased_author)
  end

  test "scopes authors by genre focus" do
    mystery_authors = Author.by_genre("Mystery")

    assert_includes mystery_authors, authors(:agatha_christie)
    assert_includes mystery_authors, authors(:mystery_author)
    assert_not_includes mystery_authors, authors(:jane_austen)
    assert_not_includes mystery_authors, authors(:stephen_king)
  end

  test "searches authors by name" do
    results = Author.search("Austen")
    assert_includes results, authors(:jane_austen)
    assert_not_includes results, authors(:stephen_king)

    # Should also search first name
    results = Author.search("Jane")
    assert_includes results, authors(:jane_austen)
  end

  test "searches authors by email" do
    results = Author.search("stephen.king@example.com")
    assert_includes results, authors(:stephen_king)
    assert_not_includes results, authors(:jane_austen)
  end

  test "search is case insensitive" do
    results = Author.search("austen")
    assert_includes results, authors(:jane_austen)

    results = Author.search("JANE")
    assert_includes results, authors(:jane_austen)
  end

  test "orders authors alphabetically by last name" do
    ordered = Author.alphabetical

    # Get all last names in order
    last_names = ordered.pluck(:last_name)

    # Verify they are sorted
    assert_equal last_names.sort, last_names
  end
end
