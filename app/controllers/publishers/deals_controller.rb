class Publishers::DealsController < ApplicationController
  include PublisherScoped

  def show
    @deals = @publisher.deals.recent
  end
end
