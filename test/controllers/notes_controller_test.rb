require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  test "creates note for author" do
    author = authors(:jane_austen)

    assert_difference("Note.count", 1) do
      post notes_path, params: {
        note: {
          content: "A new note about this author",
          notable_type: "Author",
          notable_id: author.id
        }
      }
    end

    assert_redirected_to author_path(author)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Note was successfully created/

    note = Note.last
    assert_equal "Author", note.notable_type
    assert_equal author.id, note.notable_id
    assert_equal "A new note about this author", note.content
  end

  test "creates note for book" do
    book = books(:pride_and_prejudice)

    assert_difference("Note.count", 1) do
      post notes_path, params: {
        note: {
          content: "A new note about this book",
          notable_type: "Book",
          notable_id: book.id
        }
      }
    end

    assert_redirected_to book_path(book)

    note = Note.last
    assert_equal "Book", note.notable_type
    assert_equal book.id, note.notable_id
  end

  test "creates note for deal" do
    deal = deals(:pride_and_prejudice_deal)

    assert_difference("Note.count", 1) do
      post notes_path, params: {
        note: {
          content: "A new note about this deal",
          notable_type: "Deal",
          notable_id: deal.id
        }
      }
    end

    assert_redirected_to deal_path(deal)

    note = Note.last
    assert_equal "Deal", note.notable_type
    assert_equal deal.id, note.notable_id
  end

  test "rejects note creation with invalid data" do
    author = authors(:jane_austen)

    assert_no_difference("Note.count") do
      post notes_path, params: {
        note: {
          content: "",
          notable_type: "Author",
          notable_id: author.id
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "updates note content" do
    note = notes(:author_regular_note)
    author = authors(:jane_austen)

    patch note_path(note), params: {
      note: { content: "Updated note content here" }
    }

    assert_redirected_to author_path(author)

    note.reload
    assert_equal "Updated note content here", note.content
  end

  test "pins note" do
    note = notes(:author_regular_note)
    assert_not note.pinned?

    patch note_path(note), params: {
      note: { pinned: true }
    }

    assert_redirected_to author_path(note.notable)

    note.reload
    assert note.pinned?
  end

  test "unpins note" do
    note = notes(:author_pinned_note)
    assert note.pinned?

    patch note_path(note), params: {
      note: { pinned: false }
    }

    assert_redirected_to author_path(note.notable)

    note.reload
    assert_not note.pinned?
  end

  test "deletes note" do
    note = notes(:author_regular_note)
    author = authors(:jane_austen)

    assert_difference("Note.count", -1) do
      delete note_path(note)
    end

    assert_redirected_to author_path(author)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Note was successfully deleted/
  end

  test "responds with turbo stream on create" do
    author = authors(:jane_austen)

    post notes_path, params: {
      note: {
        content: "A turbo stream note",
        notable_type: "Author",
        notable_id: author.id
      }
    }, as: :turbo_stream

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match(/turbo-stream/, response.body)
  end

  test "responds with turbo stream on delete" do
    note = notes(:author_regular_note)

    delete note_path(note), as: :turbo_stream

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match(/turbo-stream/, response.body)
  end
end
