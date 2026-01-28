require "test_helper"
require "ostruct"

class AuthorsControllerTest < ActionDispatch::IntegrationTest
  test "lists all authors" do
    get authors_path

    assert_response :ok
    assert_select "h1", "Authors"
    assert_select "[data-testid='author-row']", Author.count
  end

  test "filters authors by status" do
    get authors_path(status: "active")

    assert_response :ok
    # Should only show active authors
    Author.active.each do |author|
      assert_select "[data-testid='author-row']", text: /#{author.full_name}/
    end
  end

  test "filters authors by genre focus" do
    get authors_path(genre: "Mystery")

    assert_response :ok
    # Should show Mystery authors
    Author.by_genre("Mystery").each do |author|
      assert_select "[data-testid='author-row']", text: /#{author.full_name}/
    end
  end

  test "searches authors by name" do
    get authors_path(search: "Austen")

    assert_response :ok
    assert_select "[data-testid='author-row']", text: /Jane Austen/
    assert_select "[data-testid='author-row']", count: 1
  end

  test "shows author details" do
    author = authors(:jane_austen)

    get author_path(author)

    assert_response :ok
    assert_select "h1", author.full_name
    assert_select "[data-testid='author-email']", text: author.email
    assert_select "[data-testid='author-status']", text: /active/i
  end

  test "renders new author form" do
    get new_author_path

    assert_response :ok
    assert_select "h2", "New Author"
    assert_select "form[action='#{authors_path}']"
    assert_select "input[name='author[first_name]']"
    assert_select "input[name='author[last_name]']"
    assert_select "input[name='author[email]']"
  end

  test "creates author with valid data" do
    assert_difference("Author.count", 1) do
      post authors_path, params: {
        author: {
          first_name: "New",
          last_name: "Author",
          email: "new.author@example.com",
          status: "active"
        }
      }
    end

    assert_redirected_to author_path(Author.last)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Author was successfully created/
  end

  test "rejects author creation with invalid data" do
    assert_no_difference("Author.count") do
      post authors_path, params: {
        author: {
          first_name: "",
          last_name: "",
          email: "invalid-email"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".text-red-600", /can't be blank/
  end

  test "renders edit author form" do
    author = authors(:jane_austen)

    get edit_author_path(author)

    assert_response :ok
    assert_select "h2", "Edit Author"
    assert_select "form[action='#{author_path(author)}']"
    assert_select "input[name='author[first_name]'][value='#{author.first_name}']"
    assert_select "input[name='author[last_name]'][value='#{author.last_name}']"
  end

  test "updates author with valid data" do
    author = authors(:jane_austen)

    patch author_path(author), params: {
      author: {
        first_name: "Updated",
        last_name: "Name"
      }
    }

    assert_redirected_to author_path(author)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Author was successfully updated/

    author.reload
    assert_equal "Updated", author.first_name
    assert_equal "Name", author.last_name
  end

  test "rejects author update with invalid data" do
    author = authors(:jane_austen)

    patch author_path(author), params: {
      author: {
        first_name: "",
        last_name: ""
      }
    }

    assert_response :unprocessable_entity
    assert_select ".text-red-600", /can't be blank/
  end

  test "deletes author without associated records" do
    author = authors(:author_without_books)

    assert_difference("Author.count", -1) do
      delete author_path(author)
    end

    assert_redirected_to authors_path
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Author was successfully deleted/
  end

  test "prevents deletion of author with associated books" do
    # Now that the Book model exists, we use a real author with books
    author = authors(:jane_austen)

    assert_no_difference("Author.count") do
      delete author_path(author)
    end

    assert_redirected_to author_path(author)
    follow_redirect!
    assert_select "[data-testid='flash-alert']", text: /Cannot delete author with associated books/
  end
end
