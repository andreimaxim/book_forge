require "application_system_test_case"

class NavigationTest < ApplicationSystemTestCase
  test "displays main navigation with all sections" do
    visit root_path

    within("nav") do
      assert_link "Dashboard"
      assert_link "Authors"
      assert_link "Publishers"
      assert_link "Agents"
      assert_link "Prospects"
      assert_link "Books"
      assert_link "Deals"
    end
  end

  test "highlights current section in navigation" do
    visit root_path

    # Check within the desktop navigation specifically
    within("[data-testid='desktop-nav']") do
      dashboard_link = find_link("Dashboard")
      assert_includes dashboard_link[:class], "bg-gray-100"
      assert_includes dashboard_link[:class], "text-gray-900"
    end
  end

  test "navigation is responsive on mobile devices" do
    # Resize window to mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667)

    visit root_path

    within("nav") do
      # Mobile menu button should be visible
      assert_selector "[data-testid='mobile-menu-button']", visible: true

      # Desktop navigation should be hidden via Tailwind (hidden class on smaller screens)
      # We check that it exists but is not visible
      desktop_nav = find("[data-testid='desktop-nav']", visible: :all)
      assert desktop_nav[:class].include?("hidden"), "Desktop navigation should have 'hidden' class"

      # Click mobile menu button to reveal navigation
      find("[data-testid='mobile-menu-button']").click

      # Mobile menu should now be visible with all links
      within("[data-testid='mobile-menu']") do
        assert_link "Dashboard"
        assert_link "Authors"
        assert_link "Publishers"
        assert_link "Agents"
        assert_link "Prospects"
        assert_link "Books"
        assert_link "Deals"
      end
    end
  end
end
