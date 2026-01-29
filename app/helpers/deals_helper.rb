module DealsHelper
  def deal_status_options(include_all: false)
    options = Deal.statuses.keys.map { |s| [s.humanize, s] }
    include_all ? [["All Statuses", ""]] + options : options
  end
end
