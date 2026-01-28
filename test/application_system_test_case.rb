require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Reset window size before each test to ensure consistent starting state
  setup do
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end
end
