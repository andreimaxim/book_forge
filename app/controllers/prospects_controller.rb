class ProspectsController < ApplicationController
  before_action :set_prospect, only: %i[show edit update destroy convert decline]

  def index
    @prospects = Prospect.alphabetical

    @prospects = @prospects.by_stage(params[:stage]) if params[:stage].present?
    @prospects = @prospects.by_source(params[:source]) if params[:source].present?
    @prospects = @prospects.where(agent_id: params[:agent_id]) if params[:agent_id].present?

    case params[:follow_up]
    when "today"
      @prospects = @prospects.follow_up_today
    when "week"
      @prospects = @prospects.follow_up_this_week
    when "overdue"
      @prospects = @prospects.overdue_follow_up
    end

    @prospects = @prospects.search(params[:search]) if params[:search].present?

    @pipeline_view = params[:view] == "pipeline"
  end

  def show
  end

  def new
    @prospect = Prospect.new
  end

  def create
    @prospect = Prospect.new(prospect_params)

    if @prospect.save
      redirect_to @prospect, notice: "Prospect was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @prospect.update(prospect_params)
      redirect_to @prospect, notice: "Prospect was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @prospect.destroy
    redirect_to prospects_path, notice: "Prospect was successfully deleted."
  end

  def convert
    author = @prospect.convert_to_author!

    if author
      redirect_to author, notice: "Prospect was successfully converted to author."
    else
      redirect_to @prospect, alert: @prospect.errors.full_messages.to_sentence
    end
  end

  def decline
    reason = params[:decline_reason]

    if @prospect.decline!(reason)
      redirect_to @prospect, notice: "Prospect was marked as declined."
    else
      redirect_to @prospect, alert: @prospect.errors.full_messages.to_sentence
    end
  end

  private

  def set_prospect
    @prospect = Prospect.find(params[:id])
  end

  def prospect_params
    params.require(:prospect).permit(
      :first_name, :last_name, :email, :phone,
      :source, :stage, :genre_interest,
      :project_title, :project_description, :estimated_word_count,
      :notes, :agent_id, :last_contact_date, :follow_up_date
    )
  end
end
