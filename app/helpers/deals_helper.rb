module DealsHelper
  def deal_status_options(include_all: false)
    options = Deal.statuses.keys.map { |s| [ s.humanize, s ] }
    include_all ? [ [ "All Statuses", "" ] ] + options : options
  end

  def deal_type_options(include_all: false)
    options = Deal.deal_types.keys.map { |s| [ s.humanize, s ] }
    include_all ? [ [ "All Types", "" ] ] + options : options
  end
end
