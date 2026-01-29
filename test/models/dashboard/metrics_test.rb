require "test_helper"

class Dashboard::MetricsTest < ActiveSupport::TestCase
  # =============================================================================
  # Total Active Authors
  # =============================================================================

  test "calculates total active authors" do
    metrics = Dashboard::Metrics.new

    # Active authors from fixtures: jane_austen, stephen_king, agatha_christie,
    # author_no_email, mystery_author, author_without_books = 6
    assert_equal Author.active.count, metrics.total_active_authors
    assert metrics.total_active_authors > 0
  end

  # =============================================================================
  # Total Active Deals
  # =============================================================================

  test "calculates total active deals" do
    metrics = Dashboard::Metrics.new

    # Active deals (negotiating, pending_contract, signed, active)
    assert_equal Deal.active.count, metrics.total_active_deals
    assert metrics.total_active_deals > 0
  end

  # =============================================================================
  # Deals Count by Period
  # =============================================================================

  test "calculates deals count for current month" do
    travel_to Date.new(2026, 1, 28) do
      metrics = Dashboard::Metrics.new

      # Deals with offer_date in January 2026:
      # negotiating_deal (2026-01-10), pending_contract_deal (2026-01-05),
      # no_advance_deal (2026-01-20), this_quarter_deal (2026-01-15) = 4
      expected = Deal.where(
        offer_date: Date.current.beginning_of_month..Date.current.end_of_month
      ).count

      assert_equal expected, metrics.deals_count_for(:month)
      assert_equal 4, metrics.deals_count_for(:month)
    end
  end

  test "calculates deals count for current quarter" do
    travel_to Date.new(2026, 1, 28) do
      metrics = Dashboard::Metrics.new

      # Q1 2026 deals (same as month since all are in January):
      expected = Deal.where(
        offer_date: Date.current.beginning_of_quarter..Date.current.end_of_quarter
      ).count

      assert_equal expected, metrics.deals_count_for(:quarter)
      assert_equal 4, metrics.deals_count_for(:quarter)
    end
  end

  test "calculates deals count for current year" do
    travel_to Date.new(2026, 1, 28) do
      metrics = Dashboard::Metrics.new

      # 2026 deals: negotiating_deal, pending_contract_deal, no_advance_deal,
      # this_quarter_deal = 4
      expected = Deal.where(
        offer_date: Date.current.beginning_of_year..Date.current.end_of_year
      ).count

      assert_equal expected, metrics.deals_count_for(:year)
      assert_equal 4, metrics.deals_count_for(:year)
    end
  end

  # =============================================================================
  # Total Advance Value
  # =============================================================================

  test "calculates total advance value for period" do
    travel_to Date.new(2026, 1, 28) do
      metrics = Dashboard::Metrics.new

      # Deals in Jan 2026:
      #   negotiating_deal: 100,000
      #   pending_contract_deal: 250,000
      #   no_advance_deal: nil (0)
      #   this_quarter_deal: 350,000
      # Total: 700,000
      expected = Deal.where(
        offer_date: Date.current.beginning_of_month..Date.current.end_of_month
      ).sum(:advance_amount)

      assert_equal expected, metrics.total_advance_value(:month)
      assert_equal BigDecimal("700000"), metrics.total_advance_value(:month)
    end
  end

  # =============================================================================
  # Average Deal Size
  # =============================================================================

  test "calculates average deal size for period" do
    travel_to Date.new(2026, 1, 28) do
      metrics = Dashboard::Metrics.new

      # Deals in Jan 2026 with advance_amount:
      #   negotiating_deal: 100,000
      #   pending_contract_deal: 250,000
      #   this_quarter_deal: 350,000
      #   no_advance_deal: nil (excluded from average)
      # Average of deals with advances: (100,000 + 250,000 + 350,000) / 3 = 233,333.33
      result = metrics.average_deal_size(:month)

      assert_in_delta 233_333.33, result.to_f, 0.01
    end
  end

  test "calculates average deal size returns zero when no deals in period" do
    travel_to Date.new(2020, 1, 1) do
      metrics = Dashboard::Metrics.new

      assert_equal 0, metrics.average_deal_size(:month)
    end
  end

  # =============================================================================
  # Prospect Conversion Rate
  # =============================================================================

  test "calculates prospect conversion rate" do
    metrics = Dashboard::Metrics.new

    # From fixtures: 1 converted prospect (converted_prospect) out of 12 total
    total = Prospect.count
    converted = Prospect.where(stage: "converted").count

    expected_rate = (converted.to_f / total * 100).round(1)
    assert_equal expected_rate, metrics.prospect_conversion_rate
  end

  test "calculates prospect conversion rate returns zero when no prospects" do
    Prospect.delete_all
    metrics = Dashboard::Metrics.new

    assert_equal 0.0, metrics.prospect_conversion_rate
  end

  # =============================================================================
  # Metric Change from Previous Period
  # =============================================================================

  test "calculates metric change from previous period" do
    travel_to Date.new(2026, 1, 28) do
      metrics = Dashboard::Metrics.new

      # Current month (Jan 2026): 4 deals
      # Previous month (Dec 2025): high_commission_deal (2025-11-01 offer) - no, that's Nov.
      # Dec 2025: none with offer_date in Dec
      # So change = 4 - 0 = 4, percentage = infinite or we cap at some value
      change = metrics.metric_change(:deals_count, :month)

      assert_kind_of Hash, change
      assert change.key?(:current)
      assert change.key?(:previous)
      assert change.key?(:difference)
      assert change.key?(:percentage)
      assert_equal 4, change[:current]
    end
  end

  # =============================================================================
  # Books by Status
  # =============================================================================

  test "counts books by status" do
    metrics = Dashboard::Metrics.new

    result = metrics.books_by_status

    assert_kind_of Hash, result

    # Verify counts match actual data
    Book::STATUSES.each do |status|
      expected = Book.where(status: status).count
      assert_equal expected, result[status],
        "Expected #{expected} books with status '#{status}', got #{result[status]}"
    end

    # Verify specific known counts from fixtures
    assert result["published"] > 0, "Expected at least one published book"
    assert result["manuscript"] > 0, "Expected at least one manuscript"
  end

  # =============================================================================
  # Deals by Status
  # =============================================================================

  test "counts deals by status" do
    metrics = Dashboard::Metrics.new

    result = metrics.deals_by_status

    assert_kind_of Hash, result

    # Verify counts match actual data
    Deal.statuses.keys.each do |status|
      expected = Deal.where(status: status).count
      assert_equal expected, result[status],
        "Expected #{expected} deals with status '#{status}', got #{result[status]}"
    end

    # Verify specific known counts from fixtures
    assert result["signed"] > 0, "Expected at least one signed deal"
    assert result["negotiating"] > 0, "Expected at least one negotiating deal"
  end

  # =============================================================================
  # Top Publishers by Deal Count
  # =============================================================================

  test "returns top publishers by deal count" do
    metrics = Dashboard::Metrics.new

    result = metrics.top_publishers_by_deal_count

    assert_kind_of Array, result
    assert result.length <= 5, "Expected at most 5 top publishers"

    # Each entry should have publisher name and count
    first_entry = result.first
    assert first_entry.respond_to?(:[])
    assert first_entry.key?(:publisher)
    assert first_entry.key?(:deal_count)

    # Results should be in descending order of deal count
    counts = result.map { |entry| entry[:deal_count] }
    assert_equal counts, counts.sort.reverse,
      "Expected publishers sorted by deal count descending"

    # HarperCollins has 2 deals (negotiating_deal + this_quarter_deal)
    # so it should appear in the top
    publisher_names = result.map { |entry| entry[:publisher].name }
    assert_includes publisher_names, "HarperCollins"
  end

  # =============================================================================
  # Top Agents by Deal Count
  # =============================================================================

  test "returns top agents by deal count" do
    metrics = Dashboard::Metrics.new

    result = metrics.top_agents_by_deal_count

    assert_kind_of Array, result
    assert result.length <= 5, "Expected at most 5 top agents"

    # Each entry should have agent and count
    first_entry = result.first
    assert first_entry.respond_to?(:[])
    assert first_entry.key?(:agent)
    assert first_entry.key?(:deal_count)

    # Results should be in descending order of deal count
    counts = result.map { |entry| entry[:deal_count] }
    assert_equal counts, counts.sort.reverse,
      "Expected agents sorted by deal count descending"

    # simon_lipskar has 2 deals (the_shining_deal + audio_deal)
    agent_names = result.map { |entry| entry[:agent].full_name }
    assert_includes agent_names, "Simon Lipskar"
  end
end
