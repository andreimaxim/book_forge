class ActivitiesController < ApplicationController
  PER_PAGE = 20

  def index
    @activities = Activity.for_trackable(params[:trackable_type], params[:trackable_id])
                          .recent

    @activities = @activities.by_action(params[:action_type]) if params[:action_type].present?

    if params[:start_date].present? && params[:end_date].present?
      @activities = @activities.in_date_range(
        Date.parse(params[:start_date]).beginning_of_day,
        Date.parse(params[:end_date]).end_of_day
      )
    end

    @total_count = @activities.count
    @page = (params[:page] || 1).to_i
    @activities = @activities.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
    @total_pages = (@total_count.to_f / PER_PAGE).ceil

    @trackable = find_trackable
  end

  private

  def find_trackable
    return nil unless params[:trackable_type].present? && params[:trackable_id].present?

    params[:trackable_type].constantize.find_by(id: params[:trackable_id])
  rescue NameError
    nil
  end
end
