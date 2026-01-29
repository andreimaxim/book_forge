class PublishersController < ApplicationController
  before_action :set_publisher, only: %i[show edit update destroy]

  def index
    @publishers = Publisher.alphabetical

    @publishers = @publishers.by_size(params[:size]) if params[:size].present?
    @publishers = @publishers.where(status: params[:status]) if params[:status].present?
    @publishers = @publishers.search(params[:search]) if params[:search].present?
  end

  def show
    @books = @publisher.books
  end

  def new
    @publisher = Publisher.new
  end

  def create
    @publisher = Publisher.new(publisher_params)

    if @publisher.save
      redirect_to @publisher, notice: "Publisher was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @publisher.update(publisher_params)
      redirect_to @publisher, notice: "Publisher was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @publisher.respond_to?(:deals) && @publisher.deals.exists?
      redirect_to @publisher, alert: "Cannot delete publisher with associated deals."
    else
      @publisher.destroy
      redirect_to publishers_path, notice: "Publisher was successfully deleted."
    end
  end

  private

  def set_publisher
    @publisher = Publisher.find(params[:id])
  end

  def publisher_params
    params.require(:publisher).permit(
      :name, :imprint, :address_line1, :address_line2,
      :city, :state, :postal_code, :country,
      :phone, :website, :contact_name, :contact_email,
      :contact_phone, :size, :status, :notes
    )
  end
end
