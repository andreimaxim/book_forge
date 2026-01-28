module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :render_internal_error
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::StaleObjectError, with: :render_stale_record
  end

  private

  def render_not_found(exception)
    Rails.logger.warn("RecordNotFound: #{exception.message}")

    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found, layout: "application" }
      format.json { render json: { error: "Record not found" }, status: :not_found }
    end
  end

  def render_stale_record(exception)
    Rails.logger.warn("StaleObjectError: #{exception.message}")

    respond_to do |format|
      format.html { render "errors/stale_record", status: :conflict, layout: "application" }
      format.json { render json: { error: "Record has been modified by another user" }, status: :conflict }
    end
  end

  def render_internal_error(exception)
    Rails.logger.error("InternalServerError: #{exception.message}")
    Rails.logger.error(exception.backtrace&.first(10)&.join("\n"))

    respond_to do |format|
      format.html { render "errors/internal_error", status: :internal_server_error, layout: "application" }
      format.json { render json: { error: "Internal server error" }, status: :internal_server_error }
    end
  end
end
