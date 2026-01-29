class RepresentationsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_parent
  before_action :set_representation, only: [ :update, :destroy ]

  def create
    @representation = @parent.representations.build(representation_params)

    # Set the other side of the association based on parent type
    if @parent.is_a?(Author)
      @representation.author = @parent
    else
      @representation.agent = @parent
    end

    respond_to do |format|
      if @representation.save
        format.html { redirect_to @parent, notice: "Representation was successfully created." }
        format.turbo_stream { render turbo_stream: turbo_stream_for_create }
      else
        format.html { render_form_with_errors }
        format.turbo_stream { render turbo_stream: turbo_stream_for_errors }
      end
    end
  end

  def update
    respond_to do |format|
      if @representation.update(representation_params)
        format.html { redirect_to @parent, notice: "Representation was successfully updated." }
        format.turbo_stream { render turbo_stream: turbo_stream_for_update }
      else
        format.html { render_form_with_errors }
        format.turbo_stream { render turbo_stream: turbo_stream_for_errors }
      end
    end
  end

  def destroy
    @representation.end_representation!

    respond_to do |format|
      format.html { redirect_to @parent, notice: "Representation was ended." }
      format.turbo_stream { render turbo_stream: turbo_stream_for_destroy }
    end
  end

  private

  def set_parent
    if params[:author_id]
      @parent = Author.find(params[:author_id])
    elsif params[:agent_id]
      @parent = Agent.find(params[:agent_id])
    end
  end

  def set_representation
    @representation = @parent.representations.find(params[:id])
  end

  def representation_params
    params.require(:representation).permit(
      :author_id, :agent_id, :status, :start_date, :end_date, :primary, :notes
    )
  end

  def render_form_with_errors
    if @parent.is_a?(Author)
      @author = @parent
      @books = @author.books.recent
      @deals = @author.deals.includes(:book, :publisher, :agent).recent
      @recent_activities = Activity.for_trackable("Author", @author.id).recent.limit(5)
      render "authors/show", status: :unprocessable_entity
    else
      @agent = @parent
      @deals = @agent.deals.includes(:book, :publisher, book: :author).recent
      render "agents/show", status: :unprocessable_entity
    end
  end

  def turbo_stream_for_create
    [
      turbo_stream.prepend(representations_list_id, partial: "representations/representation", locals: { representation: @representation, parent: @parent }),
      turbo_stream.replace(new_representation_form_id, partial: "representations/form", locals: { parent: @parent, representation: @parent.representations.build }),
      turbo_stream.update("flash", partial: "shared/flash_message", locals: { type: "notice", message: "Representation was successfully created." })
    ]
  end

  def turbo_stream_for_update
    [
      turbo_stream.replace(dom_id(@representation), partial: "representations/representation", locals: { representation: @representation, parent: @parent }),
      turbo_stream.update("flash", partial: "shared/flash_message", locals: { type: "notice", message: "Representation was successfully updated." })
    ]
  end

  def turbo_stream_for_destroy
    [
      turbo_stream.replace(dom_id(@representation), partial: "representations/representation", locals: { representation: @representation, parent: @parent }),
      turbo_stream.update("flash", partial: "shared/flash_message", locals: { type: "notice", message: "Representation was ended." })
    ]
  end

  def turbo_stream_for_errors
    [
      turbo_stream.replace(new_representation_form_id, partial: "representations/form", locals: { parent: @parent, representation: @representation })
    ]
  end

  def representations_list_id
    @parent.is_a?(Author) ? "author-representations" : "agent-representations"
  end

  def new_representation_form_id
    @parent.is_a?(Author) ? "new-author-representation-form" : "new-agent-representation-form"
  end
end
