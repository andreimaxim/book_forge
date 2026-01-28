require "test_helper"

class PublishersControllerTest < ActionDispatch::IntegrationTest
  test "lists all publishers" do
    get publishers_path

    assert_response :ok
    assert_select "h1", "Publishers"
    assert_select "[data-testid='publisher-row']", Publisher.count
  end

  test "filters publishers by size" do
    get publishers_path(size: "big_five")

    assert_response :ok
    # Should only show big five publishers
    Publisher.by_size("big_five").each do |publisher|
      assert_select "[data-testid='publisher-row']", text: /#{Regexp.escape(publisher.name)}/
    end
  end

  test "filters publishers by status" do
    get publishers_path(status: "active")

    assert_response :ok
    # Should only show active publishers
    Publisher.active.each do |publisher|
      assert_select "[data-testid='publisher-row']", text: /#{Regexp.escape(publisher.name)}/
    end
  end

  test "searches publishers by name" do
    get publishers_path(search: "Penguin")

    assert_response :ok
    assert_select "[data-testid='publisher-row']", text: /Penguin Random House/
    assert_select "[data-testid='publisher-row']", count: 1
  end

  test "shows publisher details" do
    publisher = publishers(:penguin_random_house)

    get publisher_path(publisher)

    assert_response :ok
    assert_select "h1", publisher.display_name
    assert_select "[data-testid='publisher-contact-email']", text: publisher.contact_email
    assert_select "[data-testid='publisher-status']", text: /active/i
  end

  test "creates publisher with valid data" do
    assert_difference("Publisher.count", 1) do
      post publishers_path, params: {
        publisher: {
          name: "New Publishing House",
          contact_email: "contact@newpub.com",
          website: "https://www.newpub.com",
          size: "indie",
          status: "active"
        }
      }
    end

    assert_redirected_to publisher_path(Publisher.last)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Publisher was successfully created/
  end

  test "updates publisher with valid data" do
    publisher = publishers(:indie_press)

    patch publisher_path(publisher), params: {
      publisher: {
        name: "Updated Publishing House",
        contact_email: "updated@publisher.com"
      }
    }

    assert_redirected_to publisher_path(publisher)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Publisher was successfully updated/

    publisher.reload
    assert_equal "Updated Publishing House", publisher.name
    assert_equal "updated@publisher.com", publisher.contact_email
  end

  test "deletes publisher without associated records" do
    publisher = publishers(:minimal_publisher)

    assert_difference("Publisher.count", -1) do
      delete publisher_path(publisher)
    end

    assert_redirected_to publishers_path
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Publisher was successfully deleted/
  end

  test "prevents deletion of publisher with associated deals" do
    # penguin_random_house has deals in fixtures (pride_and_prejudice_deal)
    publisher = publishers(:penguin_random_house)

    # Verify the publisher actually has deals (use .exists? to bypass counter cache
    # since fixtures do not trigger counter cache callbacks)
    assert publisher.deals.exists?, "Publisher should have deals for this test"

    assert_no_difference("Publisher.count") do
      delete publisher_path(publisher)
    end

    assert_redirected_to publisher_path(publisher)
    follow_redirect!
    assert_select "[data-testid='flash-alert']", text: /Cannot delete publisher with associated deals/
  end
end
