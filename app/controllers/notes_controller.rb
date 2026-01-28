class NotesController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_note, only: [ :show, :edit, :update, :destroy ]

  NOTABLE_TYPES = %w[Author Book Deal Publisher Agent Prospect].freeze

  def show
  end

  def edit
  end

  def create
    @note = Note.new(note_params)

    respond_to do |format|
      if @note.save
        format.html { redirect_to notable_path(@note.notable), notice: "Note was successfully created." }
        format.turbo_stream { render turbo_stream: turbo_stream_for_create }
      else
        format.html { redirect_back_or_to root_path, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream_for_errors }
      end
    end
  end

  def update
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to notable_path(@note.notable), notice: "Note was successfully updated." }
        format.turbo_stream { render turbo_stream: turbo_stream_for_update }
      else
        format.html { redirect_back_or_to root_path, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream_for_errors }
      end
    end
  end

  def destroy
    notable = @note.notable
    @note.destroy

    respond_to do |format|
      format.html { redirect_to notable_path(notable), notice: "Note was successfully deleted." }
      format.turbo_stream { render turbo_stream: turbo_stream_for_destroy }
    end
  end

  private

  def set_note
    @note = Note.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:content, :pinned, :notable_type, :notable_id)
  end

  def notable_path(notable)
    case notable
    when Author then author_path(notable)
    when Book then book_path(notable)
    when Deal then deal_path(notable)
    when Publisher then publisher_path(notable)
    when Agent then agent_path(notable)
    when Prospect then prospect_path(notable)
    else root_path
    end
  end

  def turbo_stream_for_create
    [
      turbo_stream.prepend("notes-list", partial: "notes/note", locals: { note: @note }),
      turbo_stream.replace("new-note-form", partial: "notes/form", locals: { notable: @note.notable, note: Note.new(notable: @note.notable) }),
      turbo_stream.update("flash", partial: "shared/flash_message", locals: { type: "notice", message: "Note was successfully created." })
    ]
  end

  def turbo_stream_for_update
    [
      turbo_stream.replace(dom_id(@note), partial: "notes/note", locals: { note: @note }),
      turbo_stream.update("flash", partial: "shared/flash_message", locals: { type: "notice", message: "Note was successfully updated." })
    ]
  end

  def turbo_stream_for_destroy
    [
      turbo_stream.remove(dom_id(@note)),
      turbo_stream.update("flash", partial: "shared/flash_message", locals: { type: "notice", message: "Note was successfully deleted." })
    ]
  end

  def turbo_stream_for_errors
    [
      turbo_stream.replace("new-note-form", partial: "notes/form", locals: { notable: @note.notable, note: @note })
    ]
  end
end
