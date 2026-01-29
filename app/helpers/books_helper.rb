module BooksHelper
  def book_status_options(include_all: false)
    options = Book.statuses.keys.map { |s| [ s.humanize, s ] }
    include_all ? [ [ "All Statuses", "" ] ] + options : options
  end

  def book_format_options(include_all: false)
    options = Book.formats.keys.map { |s| [ s.humanize, s ] }
    include_all ? [ [ "All Formats", "" ] ] + options : options
  end
end
