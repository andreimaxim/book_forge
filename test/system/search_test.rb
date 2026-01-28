require "application_system_test_case"

class SearchSystemTest < ApplicationSystemTestCase
  test "searching from navigation bar" do
    visit root_path

    # The search bar should be visible in the navigation
    assert_selector "[data-testid='search-bar']"

    # Click the search bar to open the search overlay
    find("[data-testid='search-bar']").click

    # The search overlay/modal should appear
    assert_selector "[data-testid='search-overlay']", visible: true

    # Type a search query
    within "[data-testid='search-overlay']" do
      fill_in "search-input", with: "Austen"
    end

    # Wait for suggestions to appear
    assert_selector "[data-testid='search-suggestion']", minimum: 1, wait: 3
  end

  test "viewing grouped search results" do
    visit search_path(q: "King")

    # Results should be grouped by type
    assert_selector "[data-testid='search-result-group']", minimum: 1

    # Author group should show Stephen King
    within "[data-testid='search-result-group-Author']" do
      assert_text "Stephen King"
    end
  end

  test "filtering search results by type" do
    visit search_path(q: "Austen")

    # Type filter links should be present
    assert_selector "[data-testid='search-type-filter']", minimum: 1

    # Click on Author filter within the filters container
    within "[data-testid='search-type-filters']" do
      click_link "Authors"
    end

    # Should only show author results
    assert_selector "[data-testid='search-result-group-Author']"
    assert_no_selector "[data-testid='search-result-group-Book']"
  end

  test "navigating to result from search" do
    visit search_path(q: "Austen")

    # Click on the Jane Austen result
    within "[data-testid='search-result-group-Author']" do
      click_link "Jane Austen", match: :first
    end

    # Should navigate to the author page
    assert_selector "h1", text: "Jane Austen"
  end

  test "using keyboard shortcut to open search" do
    visit root_path

    # Ensure search overlay is not visible initially
    assert_no_selector "[data-testid='search-overlay']", visible: true

    # Press Cmd+K (Meta+K) to open search
    page.driver.browser.action.key_down(:meta).send_keys("k").key_up(:meta).perform

    # The search overlay should appear
    assert_selector "[data-testid='search-overlay']", visible: true, wait: 2

    # The search input should be focused (wait for requestAnimationFrame to complete)
    assert_selector "#search-input", wait: 2
    sleep 0.2
    active_element = page.evaluate_script("document.activeElement.id")
    assert_equal "search-input", active_element
  end

  test "using keyboard to navigate results" do
    visit root_path

    # Open search overlay
    page.driver.browser.action.key_down(:meta).send_keys("k").key_up(:meta).perform
    assert_selector "[data-testid='search-overlay']", visible: true, wait: 2

    # Type a query
    within "[data-testid='search-overlay']" do
      fill_in "search-input", with: "Austen"
    end

    # Wait for suggestions to appear
    assert_selector "[data-testid='search-suggestion']", minimum: 1, wait: 3

    # Press Escape to close
    find("#search-input").send_keys(:escape)

    assert_no_selector "[data-testid='search-overlay']", visible: true, wait: 2
  end

  test "viewing search suggestions while typing" do
    visit root_path

    # Open search
    find("[data-testid='search-bar']").click
    assert_selector "[data-testid='search-overlay']", visible: true

    # Type partial query
    within "[data-testid='search-overlay']" do
      fill_in "search-input", with: "Pride"
    end

    # Suggestions should appear with matching results
    assert_selector "[data-testid='search-suggestion']", minimum: 1, wait: 3
    assert_text "Pride and Prejudice"
  end

  test "clearing search and starting new search" do
    visit root_path

    # Open search
    find("[data-testid='search-bar']").click
    assert_selector "[data-testid='search-overlay']", visible: true

    # Type a query
    within "[data-testid='search-overlay']" do
      fill_in "search-input", with: "Austen"
    end

    # Wait for results
    assert_selector "[data-testid='search-suggestion']", minimum: 1, wait: 3

    # Clear the input
    within "[data-testid='search-overlay']" do
      fill_in "search-input", with: ""
    end

    # Suggestions should disappear
    assert_no_selector "[data-testid='search-suggestion']", wait: 2

    # Type a new query
    within "[data-testid='search-overlay']" do
      fill_in "search-input", with: "King"
    end

    # New suggestions should appear
    assert_selector "[data-testid='search-suggestion']", minimum: 1, wait: 3
    assert_text "Stephen King"
  end
end
