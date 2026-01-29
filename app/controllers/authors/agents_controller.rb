class Authors::AgentsController < ApplicationController
  include AuthorScoped

  def show
    @agents = @author.agents
    @representations = @author.representations.includes(:agent)
  end
end
