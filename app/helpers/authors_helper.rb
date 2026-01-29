module AuthorsHelper
  def author_status_options(include_all: false)
    options = Author.statuses.keys.map { |s| [ s.humanize, s ] }
    include_all ? [ [ "All Statuses", "" ] ] + options : options
  end
end
