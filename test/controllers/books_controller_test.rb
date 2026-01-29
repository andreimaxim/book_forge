require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  test "lists all books" do
    get books_path

    assert_response :ok
    assert_select "h1", "Books"
    assert_select "[data-testid='book-row']", Book.count
  end

  test "displays books in pipeline view" do
    get books_path(view: "pipeline")

    assert_response :ok
    Book.statuses.keys.each do |status|
      assert_select "[data-testid='pipeline-status-#{status}']"
    end
  end

  test "displays books in list view" do
    get books_path(view: "list")

    assert_response :ok
    assert_select "[data-testid='books-table']"
    assert_select "[data-testid='book-row']", Book.count
  end

  test "filters books by status" do
    get books_path(status: "published")

    assert_response :ok
    # Should only show published books
    published_count = Book.by_status("published").count
    assert_select "[data-testid='book-row']", published_count
  end

  test "filters books by genre" do
    get books_path(genre: "Horror")

    assert_response :ok
    # Should show Horror books
    horror_count = Book.by_genre("Horror").count
    assert_select "[data-testid='book-row']", horror_count
  end

  test "filters books by author" do
    author = authors(:stephen_king)
    get books_path(author_id: author.id)

    assert_response :ok
    # Should only show books by this author
    author_books_count = Book.by_author(author).count
    assert_select "[data-testid='book-row']", author_books_count
  end

  test "shows book details" do
    book = books(:pride_and_prejudice)

    get book_path(book)

    assert_response :ok
    assert_select "h1", book.title
    assert_select "[data-testid='book-author']", text: /Jane Austen/
    assert_select "[data-testid='book-status']", text: /published/i
    assert_select "[data-testid='status-timeline']"
  end

  test "creates book with valid data" do
    author = authors(:jane_austen)

    assert_difference("Book.count", 1) do
      post books_path, params: {
        book: {
          title: "New Book Title",
          author_id: author.id,
          genre: "Romance",
          status: "manuscript"
        }
      }
    end

    assert_redirected_to book_path(Book.last)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Book was successfully created/
  end

  test "creates book and associates with author" do
    author = authors(:stephen_king)

    post books_path, params: {
      book: {
        title: "A New Horror Story",
        author_id: author.id,
        genre: "Horror",
        status: "manuscript",
        word_count: 75000
      }
    }

    book = Book.last
    assert_equal author, book.author
    assert_equal "A New Horror Story", book.title
    assert_equal "Horror", book.genre
    assert_equal 75000, book.word_count
  end

  test "updates book status" do
    book = books(:manuscript_in_progress)

    patch book_path(book), params: {
      book: {
        status: "submitted"
      }
    }

    assert_redirected_to book_path(book)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Book was successfully updated/

    book.reload
    assert_equal "submitted", book.status
  end

  test "updates book with publication details" do
    book = books(:book_under_review)

    patch book_path(book), params: {
      book: {
        status: "published",
        isbn: "978-1-234-56789-0",
        publication_date: "2024-01-15",
        list_price: 19.99,
        format: "hardcover",
        page_count: 350
      }
    }

    assert_redirected_to book_path(book)

    book.reload
    assert_equal "published", book.status
    assert_equal "978-1-234-56789-0", book.isbn
    assert_equal Date.parse("2024-01-15"), book.publication_date
    assert_equal 19.99, book.list_price.to_f
    assert_equal "hardcover", book.format
    assert_equal 350, book.page_count
  end

  test "deletes book without deals" do
    # out_of_print_book has no deals
    book = books(:out_of_print_book)

    assert_difference("Book.count", -1) do
      delete book_path(book)
    end

    assert_redirected_to books_path
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Book was successfully deleted/
  end

  test "prevents deletion of book with active deals" do
    # pride_and_prejudice has a signed deal which is considered active
    book = books(:pride_and_prejudice)

    assert_no_difference("Book.count") do
      delete book_path(book)
    end

    assert_redirected_to book_path(book)
    follow_redirect!
    assert_select "[data-testid='flash-alert']", text: /Cannot delete book with active deals/
  end
end
