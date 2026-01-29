module AgentsHelper
  def agent_status_options(include_all: false)
    options = Agent.statuses.keys.map { |s| [ s.humanize, s ] }
    include_all ? [ [ "All Statuses", "" ] ] + options : options
  end
end
