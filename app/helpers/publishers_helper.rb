module PublishersHelper
  def publisher_status_options(include_all: false)
    options = Publisher.statuses.keys.map { |s| [ s.humanize, s ] }
    include_all ? [ [ "All Statuses", "" ] ] + options : options
  end

  def publisher_size_options(include_all: false)
    options = Publisher.sizes.keys.map { |s| [ s.humanize.titleize, s ] }
    include_all ? [ [ "All Sizes", "" ] ] + options : options
  end
end
