class Agents::DealsController < ApplicationController
  include AgentScoped

  def show
    @deals = @agent.deals.includes(:book, :publisher, book: :author).recent
  end
end
