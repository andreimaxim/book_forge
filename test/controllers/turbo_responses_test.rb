require "test_helper"

class TurboResponsesTest < ActionDispatch::IntegrationTest
  test "create responds with turbo stream when requested" do
    assert_difference("Author.count", 1) do
      post authors_path, params: {
        author: {
          first_name: "Turbo",
          last_name: "Author",
          email: "turbo.author@example.com",
          status: "active"
        }
      }, as: :turbo_stream
    end

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
    # Should contain turbo stream actions (append or prepend for the list, and flash update)
    assert_match(/turbo-stream/, response.body)
  end

  test "update responds with turbo stream when requested" do
    author = authors(:jane_austen)

    patch author_path(author), params: {
      author: {
        first_name: "Updated"
      }
    }, as: :turbo_stream

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
    assert_match(/turbo-stream/, response.body)

    author.reload
    assert_equal "Updated", author.first_name
  end

  test "destroy responds with turbo stream when requested" do
    author = authors(:author_without_books)

    assert_difference("Author.count", -1) do
      delete author_path(author), as: :turbo_stream
    end

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
    assert_match(/turbo-stream/, response.body)
    # The stream should contain a remove action
    assert_match(/action="remove"/, response.body)
  end

  test "create falls back to redirect for non-turbo requests" do
    assert_difference("Author.count", 1) do
      post authors_path, params: {
        author: {
          first_name: "Regular",
          last_name: "Author",
          email: "regular.author@example.com",
          status: "active"
        }
      }
    end

    assert_response :redirect
    assert_redirected_to author_path(Author.last)
  end
end
