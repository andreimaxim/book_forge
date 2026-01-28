class AuthorsController < ApplicationController
  before_action :set_author, only: %i[show edit update destroy]

  def index
    @authors = Author.alphabetical

    @authors = @authors.where(status: params[:status]) if params[:status].present?
    @authors = @authors.by_genre(params[:genre]) if params[:genre].present?
    @authors = @authors.search(params[:search]) if params[:search].present?
  end

  def show
    @books = @author.books.order(created_at: :desc)
    @deals = Deal.joins(:book).where(books: { author_id: @author.id }).includes(:book, :publisher, :agent).order(offer_date: :desc)
  end

  def new
    @author = Author.new
  end

  def create
    @author = Author.new(author_params)

    if @author.save
      redirect_to @author, notice: "Author was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @author.update(author_params)
      redirect_to @author, notice: "Author was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @author.respond_to?(:books) && @author.books.any?
      redirect_to @author, alert: "Cannot delete author with associated books."
    else
      @author.destroy
      redirect_to authors_path, notice: "Author was successfully deleted."
    end
  end

  private

  def set_author
    @author = Author.find(params[:id])
  end

  def author_params
    params.require(:author).permit(
      :first_name, :last_name, :email, :phone,
      :bio, :website, :genre_focus, :status,
      :date_of_birth, :notes
    )
  end
end
