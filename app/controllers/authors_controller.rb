class AuthorsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_author, only: %i[show edit update destroy]

  def index
    @authors = Author.alphabetical

    @authors = @authors.where(status: params[:status]) if params[:status].present?
    @authors = @authors.by_genre(params[:genre]) if params[:genre].present?
    @authors = @authors.search(params[:search]) if params[:search].present?
  end

  def show
    @books = @author.books.recent
    @deals = @author.deals.includes(:book, :publisher, :agent).recent
    @recent_activities = Activity.for_trackable("Author", @author.id).recent.limit(5).load
  end

  def new
    @author = Author.new
  end

  def create
    @author = Author.new(author_params)

    respond_to do |format|
      if @author.save
        format.turbo_stream { render turbo_stream: turbo_stream_for_create }
        format.html { redirect_to @author, notice: "Author was successfully created." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream_for_create_errors }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @author.update(author_params)
        format.turbo_stream { render turbo_stream: turbo_stream_for_update }
        format.html { redirect_to @author, notice: "Author was successfully updated." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream_for_update_errors }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @author.respond_to?(:books) && @author.books.exists?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("flash-messages", partial: "shared/flash_message", locals: { type: "alert", message: "Cannot delete author with associated books." })
          ]
        end
        format.html { redirect_to @author, alert: "Cannot delete author with associated books." }
      end
    else
      @author.destroy

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream_for_destroy }
        format.html { redirect_to authors_path, notice: "Author was successfully deleted." }
      end
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

  def turbo_stream_for_create
    [
      turbo_stream.prepend("authors_list_body", partial: "authors/author", locals: { author: @author }),
      turbo_stream.update("modal", ""),
      turbo_stream.update("flash-messages", partial: "shared/flash_message", locals: { type: "notice", message: "Author was successfully created." })
    ]
  end

  def turbo_stream_for_create_errors
    [
      turbo_stream.replace("modal", partial: "authors/modal_form", locals: { author: @author })
    ]
  end

  def turbo_stream_for_update
    [
      turbo_stream.update(dom_id(@author), partial: "authors/author_detail", locals: { author: @author }),
      turbo_stream.update("flash-messages", partial: "shared/flash_message", locals: { type: "notice", message: "Author was successfully updated." })
    ]
  end

  def turbo_stream_for_update_errors
    [
      turbo_stream.update(dom_id(@author), partial: "authors/inline_edit_form", locals: { author: @author })
    ]
  end

  def turbo_stream_for_destroy
    [
      turbo_stream.remove(dom_id(@author)),
      turbo_stream.update("flash-messages", partial: "shared/flash_message", locals: { type: "notice", message: "Author was successfully deleted." })
    ]
  end
end
