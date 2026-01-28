class BooksController < ApplicationController
  before_action :set_book, only: %i[show edit update destroy]

  def index
    @books = Book.includes(:author).order(created_at: :desc)

    @books = @books.by_status(params[:status]) if params[:status].present?
    @books = @books.by_genre(params[:genre]) if params[:genre].present?
    @books = @books.by_author(Author.find(params[:author_id])) if params[:author_id].present?
    @books = @books.search(params[:search]) if params[:search].present?

    @view_mode = params[:view].presence || "list"
  end

  def show
    @deals = @book.deals.includes(:publisher, :agent).order(offer_date: :desc)
  end

  def new
    @book = Book.new
    @book.author_id = params[:author_id] if params[:author_id].present?
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to @book, notice: "Book was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: "Book was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @book.has_active_deals?
      redirect_to @book, alert: "Cannot delete book with active deals."
    else
      @book.destroy
      redirect_to books_path, notice: "Book was successfully deleted."
    end
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(
      :title, :subtitle, :author_id, :genre, :subgenre,
      :word_count, :synopsis, :description, :status,
      :isbn, :publication_date, :list_price, :format,
      :page_count, :cover_image_url, :notes
    )
  end
end
