require "test_helper"

class DealsControllerTest < ActionDispatch::IntegrationTest
  test "lists all deals" do
    get deals_path

    assert_response :ok
    assert_select "h1", "Deals"
    assert_select "[data-testid='deal-row']", Deal.count
  end

  test "displays deals in pipeline view" do
    get deals_path(view: "pipeline")

    assert_response :ok
    assert_select "h1", "Deals"
    # Should have status columns for active statuses (excluding completed and terminated)
    %w[negotiating pending_contract signed active].each do |status|
      assert_select "[data-testid='pipeline-status-#{status}']"
    end
  end

  test "filters deals by status" do
    get deals_path(status: "signed")

    assert_response :ok
    # Should only show signed deals
    signed_count = Deal.by_status("signed").count
    assert_select "[data-testid='deal-row']", signed_count
  end

  test "filters deals by deal type" do
    get deals_path(deal_type: "world_rights")

    assert_response :ok
    # Should only show world_rights deals
    world_rights_count = Deal.by_deal_type("world_rights").count
    assert_select "[data-testid='deal-row']", world_rights_count
  end

  test "filters deals by publisher" do
    publisher = publishers(:penguin_random_house)
    get deals_path(publisher_id: publisher.id)

    assert_response :ok
    # Should only show deals from this publisher
    publisher_deals_count = Deal.by_publisher(publisher).count
    assert_select "[data-testid='deal-row']", publisher_deals_count
  end

  test "filters deals by date range" do
    start_date = "2025-01-01"
    end_date = "2025-12-31"
    get deals_path(start_date: start_date, end_date: end_date)

    assert_response :ok
    # Should only show deals with offer_date in range
    in_range_count = Deal.where(offer_date: Date.parse(start_date)..Date.parse(end_date)).count
    assert_select "[data-testid='deal-row']", in_range_count
  end

  test "shows deal details" do
    deal = deals(:pride_and_prejudice_deal)

    get deal_path(deal)

    assert_response :ok
    assert_select "h1", text: /#{Regexp.escape(deal.book.title)}/
    assert_select "[data-testid='deal-status']", text: /signed/i
    assert_select "[data-testid='deal-type']", text: /world rights/i
    assert_select "[data-testid='financial-summary']"
  end

  test "creates deal with valid data" do
    book = books(:book_without_word_count)
    publisher = publishers(:scholastic)

    assert_difference("Deal.count", 1) do
      post deals_path, params: {
        deal: {
          book_id: book.id,
          publisher_id: publisher.id,
          deal_type: "world_rights",
          status: "negotiating",
          advance_amount: 150000.00,
          offer_date: Date.current
        }
      }
    end

    assert_redirected_to deal_path(Deal.last)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Deal was successfully created/
  end

  test "updates deal status" do
    deal = deals(:negotiating_deal)

    patch deal_path(deal), params: {
      deal: {
        status: "pending_contract"
      }
    }

    assert_redirected_to deal_path(deal)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Deal was successfully updated/

    deal.reload
    assert_equal "pending_contract", deal.status
  end

  test "updates deal financial terms" do
    deal = deals(:negotiating_deal)

    patch deal_path(deal), params: {
      deal: {
        advance_amount: 200000.00,
        royalty_rate_hardcover: 15.00,
        royalty_rate_paperback: 10.00,
        royalty_rate_ebook: 25.00
      }
    }

    assert_redirected_to deal_path(deal)

    deal.reload
    assert_equal 200000.00, deal.advance_amount.to_f
    assert_equal 15.00, deal.royalty_rate_hardcover.to_f
    assert_equal 10.00, deal.royalty_rate_paperback.to_f
    assert_equal 25.00, deal.royalty_rate_ebook.to_f
  end

  test "associates deal with agent" do
    deal = deals(:negotiating_deal)
    agent = agents(:simon_lipskar)

    # Verify deal has no agent initially
    assert_nil deal.agent

    patch deal_path(deal), params: {
      deal: {
        agent_id: agent.id
      }
    }

    assert_redirected_to deal_path(deal)

    deal.reload
    assert_equal agent, deal.agent
  end

  test "prevents creation of duplicate deals for same book and publisher" do
    # pride_and_prejudice already has a deal with penguin_random_house
    existing_deal = deals(:pride_and_prejudice_deal)

    assert_no_difference("Deal.count") do
      post deals_path, params: {
        deal: {
          book_id: existing_deal.book_id,
          publisher_id: existing_deal.publisher_id,
          deal_type: "world_rights",
          status: "negotiating",
          advance_amount: 100000.00,
          offer_date: Date.current
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".text-red-700", text: /already has a deal with this publisher/i
  end
end
