class Authors::DealsController < ApplicationController
  include AuthorScoped

  def show
    @deals = @author.deals.includes(:book, :publisher, :agent).recent
  end
end
