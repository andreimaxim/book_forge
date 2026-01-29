require "test_helper"

class DealTest < ActiveSupport::TestCase
  # =============================================================================
  # Validation Tests
  # =============================================================================

  test "requires book" do
    deal = Deal.new(
      book: nil,
      publisher: publishers(:penguin_random_house),
      deal_type: "world_rights"
    )
    assert_not deal.valid?
    assert_includes deal.errors[:book], "must exist"
  end

  test "requires publisher" do
    deal = Deal.new(
      book: books(:pride_and_prejudice),
      publisher: nil,
      deal_type: "world_rights"
    )
    assert_not deal.valid?
    assert_includes deal.errors[:publisher], "must exist"
  end

  test "requires deal type" do
    deal = Deal.new(
      book: books(:pride_and_prejudice),
      publisher: publishers(:penguin_random_house),
      deal_type: nil
    )
    assert_not deal.valid?
    assert_includes deal.errors[:deal_type], "can't be blank"
  end

  test "validates deal type is a known value" do
    deal = Deal.new(
      book: books(:pride_and_prejudice),
      publisher: publishers(:penguin_random_house),
      deal_type: "invalid_type"
    )
    assert_not deal.valid?
    assert_includes deal.errors[:deal_type], "is not included in the list"
  end

  test "allows valid deal type values" do
    valid_types = %w[world_rights north_american translation audio film_tv]
    valid_types.each do |deal_type|
      deal = Deal.new(
        book: books(:manuscript_in_progress),
        publisher: publishers(:scholastic),
        deal_type: deal_type
      )
      assert deal.valid?, "Expected deal_type '#{deal_type}' to be valid, got errors: #{deal.errors.full_messages}"
    end
  end

  test "validates status is a known value" do
    deal = Deal.new(
      book: books(:pride_and_prejudice),
      publisher: publishers(:penguin_random_house),
      deal_type: "world_rights",
      status: "invalid_status"
    )
    assert_not deal.valid?
    assert_includes deal.errors[:status], "is not included in the list"
  end

  test "allows valid status values" do
    valid_statuses = %w[negotiating pending_contract signed active completed terminated]
    valid_statuses.each do |status|
      deal = Deal.new(
        book: books(:manuscript_in_progress),
        publisher: publishers(:scholastic),
        deal_type: "world_rights",
        status: status
      )
      assert deal.valid?, "Expected status '#{status}' to be valid, got errors: #{deal.errors.full_messages}"
    end
  end

  test "validates advance amount is not negative" do
    deal = Deal.new(
      book: books(:pride_and_prejudice),
      publisher: publishers(:penguin_random_house),
      deal_type: "world_rights",
      advance_amount: -1000.00
    )
    assert_not deal.valid?
    assert_includes deal.errors[:advance_amount], "must be greater than or equal to 0"
  end

  test "allows zero advance amount" do
    deal = Deal.new(
      book: books(:manuscript_in_progress),
      publisher: publishers(:indie_press),
      deal_type: "world_rights",
      advance_amount: 0.00
    )
    assert deal.valid?
  end

  test "allows nil advance amount" do
    deal = Deal.new(
      book: books(:manuscript_in_progress),
      publisher: publishers(:indie_press),
      deal_type: "world_rights",
      advance_amount: nil
    )
    assert deal.valid?
  end

  test "validates royalty rates are between 0 and 100" do
    deal = Deal.new(
      book: books(:pride_and_prejudice),
      publisher: publishers(:penguin_random_house),
      deal_type: "world_rights",
      royalty_rate_hardcover: 105.00
    )
    assert_not deal.valid?
    assert_includes deal.errors[:royalty_rate_hardcover], "must be less than or equal to 100"

    deal.royalty_rate_hardcover = -5.00
    assert_not deal.valid?
    assert_includes deal.errors[:royalty_rate_hardcover], "must be greater than or equal to 0"
  end

  test "validates royalty rate paperback is between 0 and 100" do
    deal = Deal.new(
      book: books(:pride_and_prejudice),
      publisher: publishers(:penguin_random_house),
      deal_type: "world_rights",
      royalty_rate_paperback: 150.00
    )
    assert_not deal.valid?
    assert_includes deal.errors[:royalty_rate_paperback], "must be less than or equal to 100"
  end

  test "validates royalty rate ebook is between 0 and 100" do
    deal = Deal.new(
      book: books(:pride_and_prejudice),
      publisher: publishers(:penguin_random_house),
      deal_type: "world_rights",
      royalty_rate_ebook: -10.00
    )
    assert_not deal.valid?
    assert_includes deal.errors[:royalty_rate_ebook], "must be greater than or equal to 0"
  end

  test "allows nil royalty rates" do
    deal = Deal.new(
      book: books(:manuscript_in_progress),
      publisher: publishers(:indie_press),
      deal_type: "audio",
      royalty_rate_hardcover: nil,
      royalty_rate_paperback: nil,
      royalty_rate_ebook: nil
    )
    assert deal.valid?
  end

  test "validates contract date is after offer date" do
    deal = Deal.new(
      book: books(:pride_and_prejudice),
      publisher: publishers(:penguin_random_house),
      deal_type: "world_rights",
      offer_date: Date.new(2024, 6, 1),
      contract_date: Date.new(2024, 5, 1)
    )
    assert_not deal.valid?
    assert_includes deal.errors[:contract_date], "must be after offer date"
  end

  test "allows contract date equal to offer date" do
    deal = Deal.new(
      book: books(:manuscript_in_progress),
      publisher: publishers(:indie_press),
      deal_type: "world_rights",
      offer_date: Date.new(2024, 6, 1),
      contract_date: Date.new(2024, 6, 1)
    )
    assert deal.valid?
  end

  test "allows nil contract date" do
    deal = Deal.new(
      book: books(:manuscript_in_progress),
      publisher: publishers(:indie_press),
      deal_type: "world_rights",
      offer_date: Date.new(2024, 6, 1),
      contract_date: nil
    )
    assert deal.valid?
  end

  test "validates delivery date is after contract date" do
    deal = Deal.new(
      book: books(:pride_and_prejudice),
      publisher: publishers(:penguin_random_house),
      deal_type: "world_rights",
      contract_date: Date.new(2024, 6, 1),
      delivery_date: Date.new(2024, 5, 1)
    )
    assert_not deal.valid?
    assert_includes deal.errors[:delivery_date], "must be after contract date"
  end

  test "allows delivery date equal to contract date" do
    deal = Deal.new(
      book: books(:manuscript_in_progress),
      publisher: publishers(:indie_press),
      deal_type: "world_rights",
      contract_date: Date.new(2024, 6, 1),
      delivery_date: Date.new(2024, 6, 1)
    )
    assert deal.valid?
  end

  test "allows nil delivery date" do
    deal = Deal.new(
      book: books(:manuscript_in_progress),
      publisher: publishers(:indie_press),
      deal_type: "world_rights",
      contract_date: Date.new(2024, 6, 1),
      delivery_date: nil
    )
    assert deal.valid?
  end

  # =============================================================================
  # Scope Tests
  # =============================================================================

  test "scopes deals by status" do
    signed_deals = Deal.by_status("signed")

    assert_includes signed_deals, deals(:pride_and_prejudice_deal)
    assert_includes signed_deals, deals(:translation_deal)
    assert_not_includes signed_deals, deals(:negotiating_deal)
    assert_not_includes signed_deals, deals(:pending_contract_deal)
  end

  test "scopes deals by deal type" do
    world_rights_deals = Deal.by_deal_type("world_rights")

    assert_includes world_rights_deals, deals(:pride_and_prejudice_deal)
    assert_includes world_rights_deals, deals(:negotiating_deal)
    assert_not_includes world_rights_deals, deals(:audio_deal)
    assert_not_includes world_rights_deals, deals(:film_tv_deal)
  end

  test "scopes deals by publisher" do
    prh_deals = Deal.by_publisher(publishers(:penguin_random_house))

    assert_includes prh_deals, deals(:pride_and_prejudice_deal)
    assert_not_includes prh_deals, deals(:the_shining_deal)
  end

  test "scopes deals by agent" do
    simon_deals = Deal.by_agent(agents(:simon_lipskar))

    assert_includes simon_deals, deals(:the_shining_deal)
    assert_includes simon_deals, deals(:audio_deal)
    assert_not_includes simon_deals, deals(:pride_and_prejudice_deal)
  end

  test "scopes active deals" do
    active_deals = Deal.active

    assert_includes active_deals, deals(:negotiating_deal)
    assert_includes active_deals, deals(:pending_contract_deal)
    assert_includes active_deals, deals(:pride_and_prejudice_deal)
    assert_includes active_deals, deals(:the_shining_deal)
    assert_not_includes active_deals, deals(:terminated_deal)
    assert_not_includes active_deals, deals(:film_tv_deal) # completed
  end

  test "scopes deals this year" do
    travel_to Date.new(2026, 1, 28) do
      this_year_deals = Deal.this_year

      assert_includes this_year_deals, deals(:negotiating_deal)
      assert_includes this_year_deals, deals(:pending_contract_deal)
      assert_includes this_year_deals, deals(:this_quarter_deal)
      assert_not_includes this_year_deals, deals(:last_year_deal)
      assert_not_includes this_year_deals, deals(:film_tv_deal)
    end
  end

  test "scopes deals this quarter" do
    travel_to Date.new(2026, 1, 28) do
      this_quarter_deals = Deal.this_quarter

      assert_includes this_quarter_deals, deals(:negotiating_deal)
      assert_includes this_quarter_deals, deals(:pending_contract_deal)
      assert_includes this_quarter_deals, deals(:this_quarter_deal)
      assert_not_includes this_quarter_deals, deals(:last_year_deal)
    end
  end

  # =============================================================================
  # Instance Method Tests
  # =============================================================================

  test "calculates agent commission" do
    deal = deals(:pride_and_prejudice_deal)
    # Agent romance_agent has 12.50% commission rate
    # Advance is 500,000
    expected_commission = 500000 * 0.125
    assert_equal expected_commission, deal.agent_commission
  end

  test "calculates agent commission returns zero when no agent" do
    deal = deals(:negotiating_deal)
    assert_equal 0.00, deal.agent_commission
  end

  test "calculates agent commission returns zero when no advance" do
    deal = deals(:no_advance_deal)
    assert_equal 0.00, deal.agent_commission
  end

  test "calculates author net advance" do
    deal = deals(:pride_and_prejudice_deal)
    # Advance: 500,000, Agent commission: 62,500 (12.5%)
    expected_net = 500000 - (500000 * 0.125)
    assert_equal expected_net, deal.author_net_advance
  end

  test "calculates author net advance returns full amount when no agent" do
    deal = deals(:negotiating_deal)
    assert_equal 100000.00, deal.author_net_advance
  end

  test "calculates author net advance returns zero when no advance" do
    deal = deals(:no_advance_deal)
    assert_equal 0.00, deal.author_net_advance
  end

  test "calculates total deal value" do
    deal = deals(:pride_and_prejudice_deal)
    # For now, total deal value equals advance amount
    assert_equal 500000.00, deal.total_deal_value
  end

  test "calculates total deal value returns zero when no advance" do
    deal = deals(:no_advance_deal)
    assert_equal 0.00, deal.total_deal_value
  end

  test "returns formatted advance" do
    deal = deals(:pride_and_prejudice_deal)
    assert_equal "$500,000.00", deal.formatted_advance
  end

  test "returns formatted advance with different currency" do
    deal = deals(:translation_deal)
    assert_equal "\u20AC50,000.00", deal.formatted_advance
  end

  test "returns formatted advance for nil amount" do
    deal = deals(:no_advance_deal)
    assert_equal "$0.00", deal.formatted_advance
  end

  test "determines if contract is signed" do
    assert deals(:pride_and_prejudice_deal).contract_signed?
    assert deals(:translation_deal).contract_signed?
    assert deals(:the_shining_deal).contract_signed? # active deals are also signed
    assert_not deals(:negotiating_deal).contract_signed?
    assert_not deals(:pending_contract_deal).contract_signed?
  end

  test "determines days to close" do
    deal = deals(:pride_and_prejudice_deal)
    # Offer date: 2024-01-15, Contract date: 2024-02-01
    # 17 days
    assert_equal 17, deal.days_to_close
  end

  test "days to close returns nil when no contract date" do
    deal = deals(:negotiating_deal)
    assert_nil deal.days_to_close
  end

  test "days to close returns nil when no offer date" do
    deal = Deal.new(
      book: books(:manuscript_in_progress),
      publisher: publishers(:indie_press),
      deal_type: "world_rights",
      offer_date: nil,
      contract_date: Date.new(2024, 2, 1)
    )
    assert_nil deal.days_to_close
  end

  # =============================================================================
  # Search Tests
  # =============================================================================

  test "searches deals by book title" do
    results = Deal.search("Pride")

    assert_includes results, deals(:pride_and_prejudice_deal)
    assert_not_includes results, deals(:the_shining_deal)
  end

  test "searches deals by author name" do
    results = Deal.search("Austen")

    assert_includes results, deals(:pride_and_prejudice_deal)
    assert_includes results, deals(:negotiating_deal) # manuscript_in_progress is by Jane Austen
    assert_not_includes results, deals(:the_shining_deal)
  end

  test "search is case insensitive" do
    results = Deal.search("pride")
    assert_includes results, deals(:pride_and_prejudice_deal)

    results = Deal.search("AUSTEN")
    assert_includes results, deals(:pride_and_prejudice_deal)
  end

  # =============================================================================
  # Association Tests
  # =============================================================================

  test "belongs to book" do
    deal = deals(:pride_and_prejudice_deal)
    assert_equal books(:pride_and_prejudice), deal.book
  end

  test "belongs to publisher" do
    deal = deals(:pride_and_prejudice_deal)
    assert_equal publishers(:penguin_random_house), deal.publisher
  end

  test "belongs to agent optionally" do
    deal = deals(:pride_and_prejudice_deal)
    assert_equal agents(:romance_agent), deal.agent

    deal_without_agent = deals(:negotiating_deal)
    assert_nil deal_without_agent.agent
  end
end
