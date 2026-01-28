require "application_system_test_case"

class BooksSystemTest < ApplicationSystemTestCase
  test "viewing the books list" do
    visit books_path

    assert_selector "h1", text: "Books"

    # Verify books from fixtures are displayed
    assert_text "Pride and Prejudice"
    assert_text "The Shining"
    assert_text "Murder on the Orient Express"

    # Verify table structure (default is list view)
    assert_selector "[data-testid='books-table']"
    assert_selector "[data-testid='book-row']", minimum: 3
  end

  test "switching between grid and list views" do
    visit books_path

    # Default should be list view
    assert_selector "[data-testid='books-table']"
    assert_no_selector "[data-testid='books-grid']"

    # Switch to grid view
    find("a[title='Grid view']").click

    # Now should show grid
    assert_selector "[data-testid='books-grid']"
    assert_no_selector "[data-testid='books-table']"
    assert_selector "[data-testid='book-card']", minimum: 3

    # Switch back to list view
    find("a[title='List view']").click

    # Should be back to table
    assert_selector "[data-testid='books-table']"
    assert_no_selector "[data-testid='books-grid']"
  end

  test "filtering books by genre" do
    visit books_path

    # Click on Romance genre filter
    click_link "Romance", match: :first

    # Should show Romance books
    assert_text "Pride and Prejudice"
    assert_text "Sense and Sensibility"

    # Should not show Horror or Mystery books
    assert_no_text "The Shining"
    assert_no_text "Murder on the Orient Express"

    # Clear filter
    click_link "Clear", match: :first

    # Now should show all books again
    assert_text "Pride and Prejudice"
    assert_text "The Shining"
    assert_text "Murder on the Orient Express"
  end

  test "creating a new book for an author" do
    author = authors(:jane_austen)

    visit books_path
    click_link "New Book"

    assert_selector "h1", text: "New Book"

    fill_in "Title", with: "Mansfield Park"
    fill_in "Subtitle", with: "A Novel"
    select "Jane Austen", from: "Author"
    fill_in "Genre", with: "Romance"
    fill_in "Subgenre", with: "Regency Romance"
    fill_in "Word Count", with: 160000
    fill_in "Synopsis", with: "A story about Fanny Price and her moral compass."

    click_button "Create Book"

    # Should redirect to book show page
    assert_text "Book was successfully created"
    assert_text "Mansfield Park"
    assert_text "Jane Austen"
    assert_text "Romance"
  end

  test "viewing book details with status timeline" do
    book = books(:pride_and_prejudice)

    visit book_path(book)

    # Header information
    assert_selector "h1", text: "Pride and Prejudice"
    assert_text "A Novel"
    assert_text "Jane Austen"

    # Status timeline should be visible
    assert_selector "[data-testid='status-timeline']"

    # For a published book, the timeline should show all statuses
    # Published is the 6th status (index 5), so previous ones should be completed
    within "[data-testid='status-timeline']" do
      assert_text "Manuscript"
      assert_text "Submitted"
      assert_text "Under review"
      assert_text "Accepted"
      assert_text "In production"
      assert_text "Published"
      assert_text "Out of print"
    end

    # Book details
    assert_text "Romance"
    assert_text "978-0-14-143951-8"
    assert_text "January 28, 1813"
    assert_text "$14.99"
    assert_text "122,000 words"

    # Navigation
    assert_link "Edit"
    assert_link "Back to Books"
  end

  test "updating book status" do
    book = books(:manuscript_in_progress)

    visit edit_book_path(book)

    assert_selector "h1", text: "Edit Book"

    # Change status from manuscript to submitted
    select "Submitted", from: "Status"
    click_button "Update Book"

    # Should redirect to show page with updated status
    assert_text "Book was successfully updated"

    # Verify the status has been updated
    within "[data-testid='book-status']" do
      assert_text "submitted"
    end
  end

  test "adding publication details to a book" do
    book = books(:manuscript_in_progress)

    visit edit_book_path(book)

    assert_selector "h1", text: "Edit Book"

    # Update status to published and add publication details
    select "Published", from: "Status"
    select "Paperback", from: "Format"
    fill_in "ISBN", with: "978-1-23456-789-0"
    # Use execute_script to set date value directly to avoid browser date input quirks
    page.execute_script("document.querySelector('input[name=\"book[publication_date]\"]').value = '2020-06-15'")
    fill_in "List Price ($)", with: "16.99"
    fill_in "Page Count", with: 320

    click_button "Update Book"

    # Should redirect to show page with updated details
    assert_text "Book was successfully updated"
    assert_text "978-1-23456-789-0"
    assert_text "June 15, 2020"
    assert_text "$16.99"
    assert_text "320 pages"
    assert_text "Paperback"
  end
end
