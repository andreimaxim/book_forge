require "test_helper"

class CounterCacheTest < ActiveSupport::TestCase
  # Fixtures bypass Active Record callbacks, so counter caches are not
  # populated during fixture loading.  Reset counters for the records
  # used in these tests so assertions are accurate.
  setup do
    Author.find_each { |a| Author.reset_counters(a.id, :books) }
    Publisher.find_each { |p| Publisher.reset_counters(p.id, :deals) }
    Agent.find_each { |a| Agent.reset_counters(a.id, :representations) }
  end

  # -------------------------------------------------------------------
  # Author books_count
  # -------------------------------------------------------------------
  test "author books count is cached" do
    author = authors(:jane_austen).reload

    # The counter cache column should reflect the number of books
    expected = author.books.count
    assert_equal expected, author.books_count,
      "books_count should match the actual number of books"

    # Adding a book should increment the counter without a COUNT query
    assert_difference -> { author.reload.books_count }, 1 do
      Book.create!(
        title: "Counter Cache Test Book",
        genre: "Fiction",
        author: author,
        status: "manuscript"
      )
    end

    # Removing a book should decrement the counter
    book = author.books.last
    assert_difference -> { author.reload.books_count }, -1 do
      book.destroy!
    end
  end

  # -------------------------------------------------------------------
  # Publisher deals_count
  # -------------------------------------------------------------------
  test "publisher deals count is cached" do
    publisher = publishers(:penguin_random_house).reload

    expected = publisher.deals.count
    assert_equal expected, publisher.deals_count,
      "deals_count should match the actual number of deals"

    author = authors(:jane_austen)
    book = Book.create!(
      title: "Publisher Counter Book",
      genre: "Fiction",
      author: author,
      status: "manuscript"
    )

    assert_difference -> { publisher.reload.deals_count }, 1 do
      Deal.create!(
        book: book,
        publisher: publisher,
        deal_type: "world_rights",
        status: "negotiating"
      )
    end
  end

  # -------------------------------------------------------------------
  # Agent representations_count
  # -------------------------------------------------------------------
  test "agent representations count is cached" do
    agent = agents(:simon_lipskar).reload

    expected = agent.representations.count
    assert_equal expected, agent.representations_count,
      "representations_count should match the actual number of representations"

    # Use an author that does not already have a representation with this agent
    author = authors(:author_without_books)

    assert_difference -> { agent.reload.representations_count }, 1 do
      Representation.create!(
        author: author,
        agent: agent,
        status: "active",
        start_date: Date.current
      )
    end
  end
end
