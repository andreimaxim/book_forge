require "test_helper"

class RelatedRecordsTest < ActionDispatch::IntegrationTest
  test "loads author books tab via turbo frame" do
    author = authors(:jane_austen)

    get author_path(author)

    assert_response :success

    # Should render books in the books tab content
    assert_select "[data-testid='books-tab-content']" do
      # Should show Pride and Prejudice
      assert_select "a[href='#{book_path(books(:pride_and_prejudice))}']"
      assert_select "a", text: /Pride and Prejudice/
    end
  end

  test "loads author deals tab via turbo frame" do
    author = authors(:jane_austen)

    get author_path(author)

    assert_response :success

    # Should render deals in the deals tab content
    assert_select "[data-testid='deals-tab-content']" do
      # Jane Austen's books have deals
      assert_select "a[href='#{deal_path(deals(:pride_and_prejudice_deal))}']"
    end
  end

  test "loads publisher deals tab via turbo frame" do
    publisher = publishers(:penguin_random_house)

    # Publisher deals tab is lazy-loaded via turbo frame, request the endpoint directly
    get publisher_deals_path(publisher)

    assert_response :success

    # Penguin Random House has the Pride and Prejudice deal
    assert_select "a[href='#{deal_path(deals(:pride_and_prejudice_deal))}']"
  end

  test "loads agent authors tab via turbo frame" do
    agent = agents(:simon_lipskar)

    get agent_path(agent)

    assert_response :success

    # Should render authors in the authors tab content (handled by representations)
    assert_select "[data-testid='authors-tab-content']" do
      # Simon Lipskar represents Jane Austen
      assert_select "a[href='#{author_path(authors(:jane_austen))}']"
    end
  end

  test "author books tab shows quick add button" do
    author = authors(:jane_austen)

    get author_path(author)

    assert_response :success

    assert_select "[data-testid='books-tab-content']" do
      assert_select "a[href='#{new_book_path(author_id: author.id)}']", text: /Add Book/
    end
  end

  test "book deals tab shows quick add button" do
    book = books(:manuscript_in_progress)

    get book_path(book)

    assert_response :success

    assert_select "[data-testid='deals-tab-content']" do
      assert_select "a[href='#{new_deal_path(book_id: book.id)}']", text: /Add Deal/
    end
  end

  test "publisher deals tab shows empty state when no deals" do
    publisher = publishers(:minimal_publisher)

    # Publisher deals tab is lazy-loaded via turbo frame, request the endpoint directly
    get publisher_deals_path(publisher)

    assert_response :success

    assert_select "p", text: /No deals yet/
  end

  test "agent deals tab shows deals with links" do
    agent = agents(:romance_agent)

    get agent_path(agent)

    assert_response :success

    assert_select "[data-testid='deals-tab-content']" do
      # romance_agent has the Pride and Prejudice deal
      assert_select "a[href='#{deal_path(deals(:pride_and_prejudice_deal))}']"
    end
  end

  test "publisher books tab shows books via deals" do
    publisher = publishers(:penguin_random_house)

    get publisher_path(publisher)

    assert_response :success

    assert_select "[data-testid='books-tab-content']" do
      # Penguin Random House has a deal for Pride and Prejudice
      assert_select "a[href='#{book_path(books(:pride_and_prejudice))}']"
    end
  end

  test "author deals tab shows deal details" do
    author = authors(:jane_austen)

    get author_path(author)

    assert_response :success

    assert_select "[data-testid='deals-tab-content']" do
      # Should show the publisher name
      assert_select "a[href='#{publisher_path(publishers(:penguin_random_house))}']"
      # Should show deal type (World rights) and status badge
      assert_select "span.bg-indigo-100", text: /World rights/
    end
  end
end
