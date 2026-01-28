require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "returns search results page" do
    get search_path(q: "Austen")

    assert_response :ok
    assert_select "h1", /Search/
    assert_select "[data-testid='search-results']"
    assert_select "[data-testid='search-result-item']", minimum: 1
  end

  test "returns search results grouped by type" do
    get search_path(q: "King")

    assert_response :ok

    # Stephen King should appear as an Author result
    assert_select "[data-testid='search-result-group']", minimum: 1
    assert_select "[data-testid='search-result-group-Author']"
  end

  test "filters search results by entity type" do
    get search_path(q: "Austen", type: "Author")

    assert_response :ok

    # Only Author results should be present
    assert_select "[data-testid='search-result-group-Author']"
    assert_select "[data-testid='search-result-group-Book']", count: 0
    assert_select "[data-testid='search-result-group-Publisher']", count: 0
  end

  test "returns empty state for no results" do
    get search_path(q: "zzzznonexistent")

    assert_response :ok
    assert_select "[data-testid='search-empty-state']"
  end

  test "responds with turbo stream for autocomplete" do
    get search_path(q: "Austen"), headers: {
      "Accept" => "text/vnd.turbo-stream.html"
    }

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
  end

  test "handles empty search query" do
    get search_path(q: "")

    assert_response :ok
    assert_select "[data-testid='search-empty-state']"
  end
end
