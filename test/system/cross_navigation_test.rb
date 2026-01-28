require "application_system_test_case"

class CrossNavigationSystemTest < ApplicationSystemTestCase
  test "viewing author's books from author page" do
    author = authors(:jane_austen)

    visit author_path(author)

    # Books tab should be active by default
    within "[data-testid='books-tab-content']" do
      # Should show Pride and Prejudice and other Jane Austen books
      assert_text "Pride and Prejudice"
      assert_text "Sense and Sensibility"

      # Should show links to book details
      assert_selector "a[href='#{book_path(books(:pride_and_prejudice))}']"
    end
  end

  test "viewing author's deals from author page" do
    author = authors(:jane_austen)

    visit author_path(author)

    # Navigate to the Deals tab
    within "[data-testid='author-tabs']" do
      click_link "Deals"
    end

    # Should see deals for Jane Austen's books
    within "[data-testid='deals-tab-content']" do
      # Pride and Prejudice has a deal with Penguin Random House
      assert_text "Pride and Prejudice"
      assert_text "Penguin Random House"

      # Should show deal status
      assert_text "Signed"
    end
  end

  test "viewing author's agents from author page" do
    author = authors(:jane_austen)

    visit author_path(author)

    # Navigate to the Agents tab
    within "[data-testid='author-tabs']" do
      click_link "Agents"
    end

    # Should see agents (already tested in representations_test, but verify it works)
    within "[data-testid='agents-tab-content']" do
      assert_text "Simon Lipskar"
      assert_text "Emily Davis"
    end
  end

  test "navigating from author's book to book details" do
    author = authors(:jane_austen)

    visit author_path(author)

    # Click on a book title to navigate to book details
    within "[data-testid='books-tab-content']" do
      click_link "Pride and Prejudice"
    end

    # Should be on the book show page
    assert_current_path book_path(books(:pride_and_prejudice))
    assert_text "Pride and Prejudice"
    assert_text "Jane Austen"
  end

  test "viewing publisher's books from publisher page" do
    publisher = publishers(:penguin_random_house)

    visit publisher_path(publisher)

    # Books tab should be active by default
    within "[data-testid='books-tab-content']" do
      # Should show books that have deals with this publisher
      assert_text "Pride and Prejudice"

      # Should have link to book
      assert_selector "a[href='#{book_path(books(:pride_and_prejudice))}']"
    end
  end

  test "viewing publisher's deals from publisher page" do
    publisher = publishers(:penguin_random_house)

    visit publisher_path(publisher)

    # Navigate to the Deals tab
    within "[data-testid='publisher-tabs']" do
      click_link "Deals"
    end

    # Should see deals with this publisher
    within "[data-testid='deals-tab-content']" do
      assert_text "Pride and Prejudice"
      assert_text "World rights"
      assert_text "$500,000.00"
    end
  end

  test "viewing agent's authors from agent page" do
    agent = agents(:simon_lipskar)

    visit agent_path(agent)

    # Authors tab should be active by default
    within "[data-testid='authors-tab-content']" do
      # Simon represents Jane Austen
      assert_text "Jane Austen"
    end
  end

  test "viewing agent's deals from agent page" do
    agent = agents(:romance_agent) # Emily Davis represents Jane Austen

    visit agent_path(agent)

    # Navigate to the Deals tab
    within "[data-testid='agent-tabs']" do
      click_link "Deals"
    end

    # romance_agent has the deal for Pride and Prejudice
    within "[data-testid='deals-tab-content']" do
      assert_text "Pride and Prejudice"
      assert_text "Penguin Random House"
    end
  end

  test "navigating from deal to related book" do
    deal = deals(:pride_and_prejudice_deal)

    visit deal_path(deal)

    # Click on the book title
    click_link "Pride and Prejudice", match: :first

    # Should be on the book show page
    assert_current_path book_path(deal.book)
    assert_text "Pride and Prejudice"
  end

  test "navigating from deal to related publisher" do
    deal = deals(:pride_and_prejudice_deal)

    visit deal_path(deal)

    # Click on the publisher name
    click_link "Penguin Random House", match: :first

    # Should be on the publisher show page
    assert_current_path publisher_path(deal.publisher)
    assert_text "Penguin Random House"
  end

  test "navigating from book to author" do
    book = books(:pride_and_prejudice)

    visit book_path(book)

    # Click on the author name
    click_link "Jane Austen"

    # Should be on the author show page
    assert_current_path author_path(book.author)
    assert_text "Jane Austen"
  end

  test "quick adding a book from author page" do
    author = authors(:jane_austen)

    visit author_path(author)

    # Should see an "Add Book" button in the books tab
    within "[data-testid='books-tab-content']" do
      click_link "Add Book"
    end

    # Should be on the new book page with author pre-selected
    assert_current_path new_book_path(author_id: author.id)

    # The author should be pre-selected in the form
    assert_selector "select[name='book[author_id]'] option[selected]", text: "Jane Austen"
  end

  test "quick adding a deal from book page" do
    book = books(:submitted_book)

    visit book_path(book)

    # Should see an "Add Deal" button in the deals tab
    within "[data-testid='deals-tab-content']" do
      click_link "Add Deal"
    end

    # Should be on the new deal page with book pre-selected
    assert_current_path new_deal_path(book_id: book.id)

    # The book should be pre-selected in the form
    assert_selector "select[name='deal[book_id]'] option[selected]", text: "The Last Mystery"
  end
end
