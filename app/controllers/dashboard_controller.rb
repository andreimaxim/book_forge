class DashboardController < ApplicationController
  def index
    @metrics = Dashboard::Metrics.new

    @active_authors = @metrics.total_active_authors
    @active_deals = @metrics.total_active_deals
    @deals_this_month = @metrics.deals_count_for(:month)
    @total_advance_month = @metrics.total_advance_value(:month)
    @conversion_rate = @metrics.prospect_conversion_rate

    @deals_count_change = @metrics.metric_change(:deals_count, :month)
    @advance_change = @metrics.metric_change(:total_advance, :month)

    @books_by_status = @metrics.books_by_status
    @deals_by_status = @metrics.deals_by_status

    @recent_items = recent_items

    # Activity timeline
    @activities = Activity.recent.limit(10)
    @activities_by_day = @activities.group_by { |a| a.created_at.to_date }
    @activity_total_count = Activity.count
    @activity_has_more = @activity_total_count > 10
  end

  private

  def recent_items
    authors = Author.order(updated_at: :desc).limit(3).map { |a| { record: a, type: "Author", name: a.full_name, path: Rails.application.routes.url_helpers.author_path(a), updated_at: a.updated_at } }
    books = Book.order(updated_at: :desc).limit(3).map { |b| { record: b, type: "Book", name: b.title, path: Rails.application.routes.url_helpers.book_path(b), updated_at: b.updated_at } }
    deals = Deal.order(updated_at: :desc).limit(3).map { |d| { record: d, type: "Deal", name: "#{d.book.title} - #{d.publisher.name}", path: Rails.application.routes.url_helpers.deal_path(d), updated_at: d.updated_at } }
    prospects = Prospect.order(updated_at: :desc).limit(3).map { |p| { record: p, type: "Prospect", name: p.full_name, path: Rails.application.routes.url_helpers.prospect_path(p), updated_at: p.updated_at } }

    (authors + books + deals + prospects)
      .sort_by { |item| item[:updated_at] }
      .reverse
      .first(10)
  end
end
