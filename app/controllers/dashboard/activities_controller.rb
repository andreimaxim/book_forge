module Dashboard
  class ActivitiesController < ApplicationController
    PER_PAGE = 10

    def index
      @activities = Activity.recent

      if params[:entity_type].present?
        @entity_type = params[:entity_type]
        @activities = @activities.where(trackable_type: @entity_type)
      end

      @total_count = @activities.count
      @page = (params[:page] || 1).to_i
      @activities = @activities.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
      @total_pages = (@total_count.to_f / PER_PAGE).ceil
      @has_more = @page < @total_pages

      # Group activities by day
      @activities_by_day = @activities.group_by { |a| a.created_at.to_date }

      respond_to do |format|
        format.html
        format.turbo_stream
      end
    end
  end
end
