require "test_helper"

class SearchTest < ActiveSupport::TestCase
  # =============================================================================
  # Search Authors
  # =============================================================================

  test "searches authors by name" do
    results = Search.call("Austen")

    author_results = results.select { |r| r[:type] == "Author" }
    assert author_results.any? { |r| r[:record] == authors(:jane_austen) }
  end

  test "searches authors by first name" do
    results = Search.call("Jane")

    author_results = results.select { |r| r[:type] == "Author" }
    assert author_results.any? { |r| r[:record] == authors(:jane_austen) }
  end

  test "searches authors by email" do
    results = Search.call("stephen.king@example.com")

    author_results = results.select { |r| r[:type] == "Author" }
    assert author_results.any? { |r| r[:record] == authors(:stephen_king) }
  end

  # =============================================================================
  # Search Publishers
  # =============================================================================

  test "searches publishers by name" do
    results = Search.call("Penguin")

    publisher_results = results.select { |r| r[:type] == "Publisher" }
    assert publisher_results.any? { |r| r[:record] == publishers(:penguin_random_house) }
  end

  # =============================================================================
  # Search Agents
  # =============================================================================

  test "searches agents by name" do
    results = Search.call("Lipskar")

    agent_results = results.select { |r| r[:type] == "Agent" }
    assert agent_results.any? { |r| r[:record] == agents(:simon_lipskar) }
  end

  test "searches agents by agency" do
    results = Search.call("Writers House")

    agent_results = results.select { |r| r[:type] == "Agent" }
    assert agent_results.any? { |r| r[:record] == agents(:simon_lipskar) }
  end

  # =============================================================================
  # Search Prospects
  # =============================================================================

  test "searches prospects by name" do
    results = Search.call("Johnson")

    prospect_results = results.select { |r| r[:type] == "Prospect" }
    assert prospect_results.any? { |r| r[:record] == prospects(:new_prospect) }
  end

  test "searches prospects by project title" do
    results = Search.call("Midnight Garden")

    prospect_results = results.select { |r| r[:type] == "Prospect" }
    assert prospect_results.any? { |r| r[:record] == prospects(:new_prospect) }
  end

  # =============================================================================
  # Search Books
  # =============================================================================

  test "searches books by title" do
    results = Search.call("Pride and Prejudice")

    book_results = results.select { |r| r[:type] == "Book" }
    assert book_results.any? { |r| r[:record] == books(:pride_and_prejudice) }
  end

  test "searches books by ISBN" do
    results = Search.call("978-0-14-143951-8")

    book_results = results.select { |r| r[:type] == "Book" }
    assert book_results.any? { |r| r[:record] == books(:pride_and_prejudice) }
  end

  # =============================================================================
  # Search Deals
  # =============================================================================

  test "searches deals by book title" do
    results = Search.call("Shining")

    deal_results = results.select { |r| r[:type] == "Deal" }
    assert deal_results.any? { |r| r[:record] == deals(:the_shining_deal) }
  end

  # =============================================================================
  # Grouped Results
  # =============================================================================

  test "returns results grouped by entity type" do
    # "King" matches author Stephen King, and through books his deals too
    results = Search.call("King")
    grouped = Search.call_grouped("King")

    assert grouped.is_a?(Hash)
    assert grouped.key?("Author")
    assert grouped["Author"].any? { |r| r[:record] == authors(:stephen_king) }
  end

  # =============================================================================
  # Relevance Score
  # =============================================================================

  test "returns results with relevance score" do
    results = Search.call("Austen")

    results.each do |result|
      assert result.key?(:relevance), "Expected result to have a :relevance key"
      assert result[:relevance].is_a?(Numeric), "Expected :relevance to be numeric"
      assert result[:relevance] > 0, "Expected :relevance to be positive"
    end
  end

  # =============================================================================
  # Limits
  # =============================================================================

  test "limits total results" do
    results = Search.call("a", limit: 3)
    assert results.size <= 3
  end

  test "defaults to 50 results limit" do
    search = Search.new("a")
    assert_equal 50, search.limit
  end

  # =============================================================================
  # Highlighting
  # =============================================================================

  test "highlights matching terms in results" do
    results = Search.call("Austen")

    author_result = results.find { |r| r[:type] == "Author" && r[:record] == authors(:jane_austen) }
    assert author_result, "Expected to find Jane Austen in results"
    assert author_result[:highlight].include?("<mark>"), "Expected highlight to contain <mark> tags"
    assert author_result[:highlight].include?("Austen"), "Expected highlight to contain the name"
  end

  # =============================================================================
  # Special Characters and Edge Cases
  # =============================================================================

  test "handles special characters in query" do
    # Should not raise an error with SQL special characters
    results = Search.call("O'Brien")
    assert results.is_a?(Array)

    results = Search.call("Simon & Schuster")
    assert results.is_a?(Array)

    results = Search.call("100%")
    assert results.is_a?(Array)

    results = Search.call("test's \"quoted\"")
    assert results.is_a?(Array)
  end

  test "handles empty query" do
    results = Search.call("")
    assert_equal [], results

    results = Search.call(nil)
    assert_equal [], results

    results = Search.call("   ")
    assert_equal [], results
  end

  # =============================================================================
  # Filtering by Entity Type
  # =============================================================================

  test "filters search by entity type" do
    results = Search.call("King", entity_type: "Author")

    assert results.all? { |r| r[:type] == "Author" }
    assert results.any? { |r| r[:record] == authors(:stephen_king) }
  end

  test "filters search by entity type returns only that type" do
    results = Search.call("King", entity_type: "Author")

    types = results.map { |r| r[:type] }.uniq
    assert_equal [ "Author" ], types
  end

  test "filters search by book entity type" do
    results = Search.call("Shining", entity_type: "Book")

    assert results.all? { |r| r[:type] == "Book" }
    assert results.any? { |r| r[:record] == books(:the_shining) }
  end

  test "filters search by publisher entity type" do
    results = Search.call("Penguin", entity_type: "Publisher")

    assert results.all? { |r| r[:type] == "Publisher" }
    assert results.any? { |r| r[:record] == publishers(:penguin_random_house) }
  end

  # =============================================================================
  # Case Insensitivity
  # =============================================================================

  test "search is case insensitive" do
    results_lower = Search.call("austen")
    results_upper = Search.call("AUSTEN")

    author_lower = results_lower.select { |r| r[:type] == "Author" }
    author_upper = results_upper.select { |r| r[:type] == "Author" }

    assert author_lower.any? { |r| r[:record] == authors(:jane_austen) }
    assert author_upper.any? { |r| r[:record] == authors(:jane_austen) }
  end
end
