class Publishers::BooksController < ApplicationController
  include PublisherScoped

  def show
    @books = @publisher.books
  end
end
