require "test_helper"

class QueryPerformanceTest < ActionDispatch::IntegrationTest
  # Helper to count SQL SELECT queries executed within a block.
  # Ignores schema/internal queries (SHOW, pg_%, SAVEPOINT, etc.).
  def count_queries(&block)
    queries = []
    counter = lambda do |_name, _start, _finish, _id, payload|
      sql = payload[:sql]
      next if sql.blank?
      next if sql.match?(/\A\s*(BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE|SHOW|SET)\b/i)
      next if sql.include?("pg_")
      next if sql.include?("schema_migrations")
      next if sql.include?("ar_internal_metadata")
      next if sql.include?("TRANSACTION")
      queries << sql
    end

    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    queries.size
  end

  # -------------------------------------------------------------------
  # Authors index
  # -------------------------------------------------------------------
  test "authors index loads with constant queries regardless of record count" do
    # Measure query count with existing fixtures
    baseline_count = count_queries { get authors_path }
    assert_response :ok

    # Add more authors to the database
    10.times do |i|
      Author.create!(
        first_name: "Perf#{i}",
        last_name: "Author#{i}",
        status: "active"
      )
    end

    scaled_count = count_queries { get authors_path }
    assert_response :ok

    # Query count must stay constant (N+1 would increase linearly).
    # Allow a small tolerance for possible cache/count differences.
    assert_equal baseline_count, scaled_count,
      "Author index query count grew from #{baseline_count} to #{scaled_count} " \
      "after adding records (possible N+1)"
  end

  # -------------------------------------------------------------------
  # Publishers index
  # -------------------------------------------------------------------
  test "publishers index loads with constant queries regardless of record count" do
    baseline_count = count_queries { get publishers_path }
    assert_response :ok

    10.times do |i|
      Publisher.create!(
        name: "Perf Publisher #{i}",
        status: "active"
      )
    end

    scaled_count = count_queries { get publishers_path }
    assert_response :ok

    assert_equal baseline_count, scaled_count,
      "Publisher index query count grew from #{baseline_count} to #{scaled_count} " \
      "after adding records (possible N+1)"
  end

  # -------------------------------------------------------------------
  # Books index
  # -------------------------------------------------------------------
  test "books index loads with constant queries regardless of record count" do
    author = authors(:jane_austen)

    baseline_count = count_queries { get books_path }
    assert_response :ok

    10.times do |i|
      Book.create!(
        title: "Perf Book #{i}",
        genre: "Fiction",
        author: author,
        status: "manuscript"
      )
    end

    scaled_count = count_queries { get books_path }
    assert_response :ok

    assert_equal baseline_count, scaled_count,
      "Books index query count grew from #{baseline_count} to #{scaled_count} " \
      "after adding records (possible N+1)"
  end

  # -------------------------------------------------------------------
  # Deals index
  # -------------------------------------------------------------------
  test "deals index loads with constant queries regardless of record count" do
    author = authors(:jane_austen)
    publisher = publishers(:penguin_random_house)

    baseline_count = count_queries { get deals_path }
    assert_response :ok

    10.times do |i|
      book = Book.create!(
        title: "Deal Perf Book #{i}",
        genre: "Fiction",
        author: author,
        status: "manuscript"
      )
      Deal.create!(
        book: book,
        publisher: publisher,
        deal_type: "world_rights",
        status: "negotiating",
        offer_date: Date.current
      )
    end

    scaled_count = count_queries { get deals_path }
    assert_response :ok

    assert_equal baseline_count, scaled_count,
      "Deals index query count grew from #{baseline_count} to #{scaled_count} " \
      "after adding records (possible N+1)"
  end

  # -------------------------------------------------------------------
  # Dashboard
  # -------------------------------------------------------------------
  test "dashboard loads with acceptable query count" do
    # The dashboard makes multiple aggregation queries (counts, sums, recent items).
    # We allow a reasonable ceiling but ensure it does not blow up.
    max_acceptable_queries = 30

    query_count = count_queries { get root_path }
    assert_response :ok

    assert query_count <= max_acceptable_queries,
      "Dashboard executed #{query_count} queries, expected at most #{max_acceptable_queries}"
  end

  # -------------------------------------------------------------------
  # Search
  # -------------------------------------------------------------------
  test "search executes in acceptable time" do
    # Ensure search completes within a reasonable wall-clock budget.
    max_duration_seconds = 2.0

    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    get search_path(q: "King")
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

    assert_response :ok
    assert elapsed < max_duration_seconds,
      "Search took #{elapsed.round(3)}s, expected under #{max_duration_seconds}s"
  end
end
