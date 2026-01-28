class DealsController < ApplicationController
  before_action :set_deal, only: %i[show edit update destroy]

  def index
    @deals = Deal.includes({ book: :author }, :publisher, :agent)

    @deals = @deals.by_status(params[:status]) if params[:status].present?
    @deals = @deals.by_deal_type(params[:deal_type]) if params[:deal_type].present?
    @deals = @deals.by_publisher(params[:publisher_id]) if params[:publisher_id].present?
    @deals = @deals.by_agent(params[:agent_id]) if params[:agent_id].present?

    if params[:start_date].present? && params[:end_date].present?
      @deals = @deals.where(offer_date: Date.parse(params[:start_date])..Date.parse(params[:end_date]))
    elsif params[:start_date].present?
      @deals = @deals.where("offer_date >= ?", Date.parse(params[:start_date]))
    elsif params[:end_date].present?
      @deals = @deals.where("offer_date <= ?", Date.parse(params[:end_date]))
    end

    @deals = @deals.search(params[:search]) if params[:search].present?

    @deals = @deals.order(offer_date: :desc)

    @pipeline_view = params[:view] == "pipeline"
  end

  def show
    @recent_activities = Activity.for_trackable("Deal", @deal.id).recent.limit(5)
  end

  def new
    @deal = Deal.new
    @deal.book_id = params[:book_id] if params[:book_id].present?
  end

  def create
    @deal = Deal.new(deal_params)

    if @deal.save
      redirect_to @deal, notice: "Deal was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @deal.update(deal_params)
      redirect_to @deal, notice: "Deal was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @deal.destroy
    redirect_to deals_path, notice: "Deal was successfully deleted."
  end

  private

  def set_deal
    @deal = Deal.find(params[:id])
  end

  def deal_params
    params.require(:deal).permit(
      :book_id, :publisher_id, :agent_id,
      :deal_type, :status,
      :advance_amount, :advance_currency,
      :royalty_rate_hardcover, :royalty_rate_paperback, :royalty_rate_ebook,
      :offer_date, :contract_date, :delivery_date, :publication_date,
      :option_books, :terms_summary, :notes
    )
  end
end
