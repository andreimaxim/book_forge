require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "health check returns success status" do
    get health_path

    assert_response :ok
  end

  test "health check includes database connection status" do
    get health_path

    assert_response :ok
    json_response = response.parsed_body
    assert_equal "ok", json_response["database"]
  end

  test "health check reports database error when connection fails" do
    ActiveRecord::Base.connection.stubs(:execute).raises(StandardError.new("Connection failed"))

    get health_path

    assert_response :service_unavailable
    json_response = response.parsed_body
    assert_equal "error", json_response["database"]
  end
end
