module PublisherScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_publisher
  end

  private

  def set_publisher
    @publisher = Publisher.find(params[:publisher_id])
  end
end
