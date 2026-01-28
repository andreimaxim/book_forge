class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @entity_type = params[:type]

    if @query.present?
      @grouped_results = Search.call_grouped(@query, entity_type: @entity_type)
      @total_count = @grouped_results.values.flatten.size
    else
      @grouped_results = {}
      @total_count = 0
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
