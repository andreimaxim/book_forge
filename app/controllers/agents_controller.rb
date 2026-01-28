class AgentsController < ApplicationController
  before_action :set_agent, only: %i[show edit update destroy]

  def index
    @agents = Agent.alphabetical

    @agents = @agents.where(status: params[:status]) if params[:status].present?
    @agents = @agents.by_genre(params[:genre]) if params[:genre].present?
    @agents = @agents.by_agency(params[:agency]) if params[:agency].present?
    @agents = @agents.search(params[:search]) if params[:search].present?

    @group_by_agency = params[:group_by] == "agency"
  end

  def show
    @deals = @agent.deals.includes(:book, :publisher, book: :author).order(offer_date: :desc)
  end

  def new
    @agent = Agent.new
  end

  def create
    @agent = Agent.new(agent_params)

    if @agent.save
      redirect_to @agent, notice: "Agent was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @agent.update(agent_params)
      redirect_to @agent, notice: "Agent was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @agent.respond_to?(:representations) && @agent.representations.exists?
      redirect_to @agent, alert: "Cannot delete agent with associated representations."
    else
      @agent.destroy
      redirect_to agents_path, notice: "Agent was successfully deleted."
    end
  end

  private

  def set_agent
    @agent = Agent.find(params[:id])
  end

  def agent_params
    params.require(:agent).permit(
      :first_name, :last_name, :email, :phone,
      :agency_name, :agency_website,
      :address_line1, :address_line2, :city, :state, :postal_code, :country,
      :commission_rate, :genres_represented, :status, :notes
    )
  end
end
