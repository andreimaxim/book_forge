module AgentScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_agent
  end

  private

  def set_agent
    @agent = Agent.find(params[:agent_id])
  end
end
