class HealthController < ApplicationController
  def show
    database_status = check_database_connection
    http_status = database_status == "ok" ? :ok : :service_unavailable

    render json: {
      status: database_status == "ok" ? "ok" : "error",
      database: database_status
    }, status: http_status
  end

  private

  def check_database_connection
    ActiveRecord::Base.connection.execute("SELECT 1")
    "ok"
  rescue StandardError
    "error"
  end
end
