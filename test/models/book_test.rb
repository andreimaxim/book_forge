require "test_helper"

class BookTest < ActiveSupport::TestCase
  # =============================================================================
  # Validation Tests
  # =============================================================================

  test "requires title" do
    book = Book.new(title: nil, author: authors(:jane_austen), genre: "Romance")
    assert_not book.valid?
    assert_includes book.errors[:title], "can't be blank"
  end

  test "requires author" do
    book = Book.new(title: "Test Book", author: nil, genre: "Romance")
    assert_not book.valid?
    assert_includes book.errors[:author], "must exist"
  end

  test "requires genre" do
    book = Book.new(title: "Test Book", author: authors(:jane_austen), genre: nil)
    assert_not book.valid?
    assert_includes book.errors[:genre], "can't be blank"
  end

  test "validates word count is positive" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      word_count: -100
    )
    assert_not book.valid?
    assert_includes book.errors[:word_count], "must be greater than 0"
  end

  test "allows nil word count" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      word_count: nil
    )
    assert book.valid?
  end

  test "allows positive word count" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      word_count: 50000
    )
    assert book.valid?
  end

  test "validates ISBN format when provided - ISBN-13" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      isbn: "978-3-16-148410-0"
    )
    assert book.valid?
  end

  test "validates ISBN format when provided - ISBN-13 without hyphens" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      isbn: "9780141439518"
    )
    assert book.valid?
  end

  test "validates ISBN format when provided - ISBN-10" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      isbn: "0-316-76948-7"
    )
    assert book.valid?
  end

  test "validates ISBN format when provided - ISBN-10 without hyphens" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      isbn: "0306406152"
    )
    assert book.valid?
  end

  test "rejects invalid ISBN format" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      isbn: "invalid-isbn"
    )
    assert_not book.valid?
    assert_includes book.errors[:isbn], "is invalid"
  end

  test "allows nil ISBN" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      isbn: nil
    )
    assert book.valid?
  end

  test "validates ISBN uniqueness when provided" do
    existing_book = books(:pride_and_prejudice)
    book = Book.new(
      title: "Another Book",
      author: authors(:stephen_king),
      genre: "Horror",
      isbn: existing_book.isbn
    )
    assert_not book.valid?
    assert_includes book.errors[:isbn], "has already been taken"
  end

  test "allows multiple books with nil ISBN" do
    Book.create!(
      title: "Book One",
      author: authors(:jane_austen),
      genre: "Romance",
      isbn: nil
    )
    book2 = Book.new(
      title: "Book Two",
      author: authors(:jane_austen),
      genre: "Romance",
      isbn: nil
    )
    assert book2.valid?
  end

  test "raises error for invalid status value" do
    assert_raises(ArgumentError) do
      Book.new(
        title: "Test Book",
        author: authors(:jane_austen),
        genre: "Romance",
        status: "unknown_status"
      )
    end
  end

  test "allows valid status values" do
    valid_statuses = %w[manuscript submitted under_review accepted in_production published out_of_print]
    valid_statuses.each do |valid_status|
      book = Book.new(
        title: "Test Book",
        author: authors(:jane_austen),
        genre: "Romance",
        status: valid_status
      )
      assert book.valid?, "Expected status '#{valid_status}' to be valid"
    end
  end

  test "validates list price is positive when provided" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      list_price: -10.00
    )
    assert_not book.valid?
    assert_includes book.errors[:list_price], "must be greater than 0"
  end

  test "allows nil list price" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      list_price: nil
    )
    assert book.valid?
  end

  test "allows positive list price" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      list_price: 19.99
    )
    assert book.valid?
  end

  test "validates page count is positive when provided" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      page_count: -50
    )
    assert_not book.valid?
    assert_includes book.errors[:page_count], "must be greater than 0"
  end

  test "allows nil page count" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      page_count: nil
    )
    assert book.valid?
  end

  test "allows positive page count" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      page_count: 350
    )
    assert book.valid?
  end

  test "validates publication date is not in future for published books" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      status: "published",
      publication_date: Date.current + 1.year
    )
    assert_not book.valid?
    assert_includes book.errors[:publication_date], "can't be in the future for published books"
  end

  test "allows future publication date for non-published books" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      status: "in_production",
      publication_date: Date.current + 1.year
    )
    assert book.valid?
  end

  test "allows past publication date for published books" do
    book = Book.new(
      title: "Test Book",
      author: authors(:jane_austen),
      genre: "Romance",
      status: "published",
      publication_date: Date.current - 1.year
    )
    assert book.valid?
  end

  # =============================================================================
  # Scope Tests
  # =============================================================================

  test "scopes books by status" do
    published_books = Book.by_status("published")

    assert_includes published_books, books(:pride_and_prejudice)
    assert_includes published_books, books(:the_shining)
    assert_not_includes published_books, books(:manuscript_in_progress)
    assert_not_includes published_books, books(:book_under_review)
  end

  test "scopes books by genre" do
    romance_books = Book.by_genre("Romance")

    assert_includes romance_books, books(:pride_and_prejudice)
    assert_includes romance_books, books(:sense_and_sensibility)
    assert_not_includes romance_books, books(:the_shining)
    assert_not_includes romance_books, books(:murder_on_orient_express)
  end

  test "scopes books by author" do
    austen_books = Book.by_author(authors(:jane_austen))

    assert_includes austen_books, books(:pride_and_prejudice)
    assert_includes austen_books, books(:sense_and_sensibility)
    assert_includes austen_books, books(:manuscript_in_progress)
    assert_not_includes austen_books, books(:the_shining)
  end

  test "scopes published books" do
    published = Book.published

    assert_includes published, books(:pride_and_prejudice)
    assert_includes published, books(:the_shining)
    assert_includes published, books(:murder_on_orient_express)
    assert_not_includes published, books(:manuscript_in_progress)
    assert_not_includes published, books(:book_under_review)
  end

  test "scopes manuscripts awaiting deals" do
    manuscripts = Book.manuscripts_awaiting_deals

    assert_includes manuscripts, books(:manuscript_in_progress)
    assert_not_includes manuscripts, books(:pride_and_prejudice)
    assert_not_includes manuscripts, books(:submitted_book)
  end

  # =============================================================================
  # Search Tests
  # =============================================================================

  test "searches books by title" do
    results = Book.search("Pride")

    assert_includes results, books(:pride_and_prejudice)
    assert_not_includes results, books(:the_shining)
  end

  test "search by title is case insensitive" do
    results = Book.search("pride")
    assert_includes results, books(:pride_and_prejudice)

    results = Book.search("PRIDE")
    assert_includes results, books(:pride_and_prejudice)
  end

  test "searches books by author name" do
    results = Book.search("Austen")

    assert_includes results, books(:pride_and_prejudice)
    assert_includes results, books(:sense_and_sensibility)
    assert_not_includes results, books(:the_shining)
  end

  test "searches books by ISBN" do
    results = Book.search("978-0-14-143951-8")

    assert_includes results, books(:pride_and_prejudice)
    assert_not_includes results, books(:the_shining)
  end

  # =============================================================================
  # Instance Method Tests
  # =============================================================================

  test "determines if book is published" do
    assert books(:pride_and_prejudice).published?
    assert_not books(:manuscript_in_progress).published?
    assert_not books(:book_under_review).published?
  end

  test "determines if book has active deals" do
    # pride_and_prejudice has a signed deal which is active
    assert books(:pride_and_prejudice).has_active_deals?
    # book_without_word_count has only negotiating deals (also active)
    assert books(:book_without_word_count).has_active_deals?
    # out_of_print_book has no deals
    assert_not books(:out_of_print_book).has_active_deals?
  end

  test "calculates time since submission" do
    book = books(:submitted_book)
    book.update!(created_at: 30.days.ago)

    assert_in_delta 30, book.days_since_submission, 1
  end

  test "returns nil for days since submission if not submitted" do
    book = books(:manuscript_in_progress)
    assert_nil book.days_since_submission
  end

  test "returns formatted word count" do
    book = books(:pride_and_prejudice)
    assert_equal "122,000 words", book.formatted_word_count
  end

  test "returns formatted word count for large numbers" do
    book = books(:it)
    assert_equal "445,000 words", book.formatted_word_count
  end

  test "returns nil for formatted word count when word count is nil" do
    book = books(:book_without_word_count)
    assert_nil book.formatted_word_count
  end

  # =============================================================================
  # Association Tests
  # =============================================================================

  test "belongs to author" do
    book = books(:pride_and_prejudice)
    assert_equal authors(:jane_austen), book.author
  end
end
