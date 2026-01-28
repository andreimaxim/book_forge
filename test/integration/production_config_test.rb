require "test_helper"

class ProductionConfigTest < ActionDispatch::IntegrationTest
  # === Main Flow: Health check endpoint works ===

  test "health check endpoint returns success" do
    get health_path

    assert_response :ok
    json = response.parsed_body
    assert_equal "ok", json["status"]
  end

  test "health check returns JSON content type" do
    get health_path

    assert_equal "application/json", response.media_type
  end

  # === Main Flow: Database connection verified ===

  test "database connection is established" do
    get health_path

    assert_response :ok
    json = response.parsed_body
    assert_equal "ok", json["database"]
  end

  test "health check reports error when database is unavailable" do
    ActiveRecord::Base.connection.stubs(:execute).raises(StandardError.new("Connection refused"))

    get health_path

    assert_response :service_unavailable
    json = response.parsed_body
    assert_equal "error", json["status"]
    assert_equal "error", json["database"]
  end

  # === Main Flow: Static assets are served ===

  test "static assets are served correctly" do
    get "/robots.txt"

    assert_response :ok
  end

  test "static icon asset is accessible" do
    get "/icon.png"

    assert_response :ok
  end

  # === Postconditions: Production configuration files exist ===

  test "Procfile defines web process" do
    procfile = File.read(Rails.root.join("Procfile"))

    assert_match(/^web:\s+bundle exec puma/, procfile)
  end

  test "Procfile defines release process" do
    procfile = File.read(Rails.root.join("Procfile"))

    assert_match(/^release:\s+/, procfile)
  end

  test "Puma is configured with thread settings" do
    puma_config = File.read(Rails.root.join("config", "puma.rb"))

    assert_match(/threads_count\s*=\s*ENV\.fetch\("RAILS_MAX_THREADS"/, puma_config)
    assert_match(/threads\s+threads_count/, puma_config)
  end

  test "Puma is configured with port from environment" do
    puma_config = File.read(Rails.root.join("config", "puma.rb"))

    assert_match(/port\s+ENV\.fetch\("PORT"/, puma_config)
  end

  test "Puma is configured with workers for production concurrency" do
    puma_config = File.read(Rails.root.join("config", "puma.rb"))

    assert_match(
      /workers\s+ENV\.fetch\("WEB_CONCURRENCY"/,
      puma_config,
      "Puma must configure workers from WEB_CONCURRENCY environment variable"
    )
  end

  test "Puma preloads app for copy-on-write memory savings" do
    puma_config = File.read(Rails.root.join("config", "puma.rb"))

    assert_match(
      /preload_app!/,
      puma_config,
      "Puma should preload the app for better memory usage with workers"
    )
  end

  test "production environment logs to STDOUT" do
    production_config = File.read(Rails.root.join("config", "environments", "production.rb"))

    assert_match(/logger.*STDOUT/i, production_config)
  end

  test "production environment uses request_id log tag" do
    production_config = File.read(Rails.root.join("config", "environments", "production.rb"))

    assert_match(/log_tags.*request_id/, production_config)
  end

  test "production environment configures log level from environment" do
    production_config = File.read(Rails.root.join("config", "environments", "production.rb"))

    assert_match(/RAILS_LOG_LEVEL/, production_config)
  end

  test "bin/release script exists and is executable" do
    release_script = Rails.root.join("bin", "release")

    assert File.exist?(release_script), "bin/release script must exist"
    assert File.executable?(release_script), "bin/release script must be executable"
  end

  test "bin/release script runs database migrations" do
    release_content = File.read(Rails.root.join("bin", "release"))

    assert_match(/db:migrate/, release_content)
  end

  test "database.yml configures connection pool from environment" do
    db_config = File.read(Rails.root.join("config", "database.yml"))

    assert_match(/RAILS_MAX_THREADS/, db_config)
  end

  test "production database uses environment variable for password" do
    db_config = File.read(Rails.root.join("config", "database.yml"))

    assert_match(/BOOKFORGE_DATABASE_PASSWORD/, db_config)
  end
end
