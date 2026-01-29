module Dashboard
  class Metrics
    PERIOD_METHODS = {
      month: :beginning_of_month,
      quarter: :beginning_of_quarter,
      year: :beginning_of_year
    }.freeze

    # =========================================================================
    # Active Counts
    # =========================================================================

    def total_active_authors
      Author.active.count
    end

    def total_active_deals
      Deal.active.count
    end

    # =========================================================================
    # Deals Count by Period
    # =========================================================================

    def deals_count_for(period)
      deals_in_period(period).count
    end

    # =========================================================================
    # Financial Metrics
    # =========================================================================

    def total_advance_value(period)
      deals_in_period(period).sum(:advance_amount)
    end

    def average_deal_size(period)
      deals = deals_in_period(period).where.not(advance_amount: nil)
      return 0 if deals.empty?

      deals.average(:advance_amount).round(2)
    end

    # =========================================================================
    # Conversion Rate
    # =========================================================================

    def prospect_conversion_rate
      total = Prospect.count
      return 0.0 if total.zero?

      converted = Prospect.where(stage: "converted").count
      (converted.to_f / total * 100).round(1)
    end

    # =========================================================================
    # Metric Change from Previous Period
    # =========================================================================

    def metric_change(metric, period)
      current_range = period_range(period)
      previous_range = previous_period_range(period)

      current_value = calculate_metric_for_range(metric, current_range)
      previous_value = calculate_metric_for_range(metric, previous_range)

      difference = current_value - previous_value
      percentage = if previous_value.zero?
        current_value.zero? ? 0.0 : Float::INFINITY
      else
        ((difference.to_f / previous_value) * 100).round(1)
      end

      {
        current: current_value,
        previous: previous_value,
        difference: difference,
        percentage: percentage
      }
    end

    # =========================================================================
    # Status Breakdowns
    # =========================================================================

    def books_by_status
      counts = Book.group(:status).count
      Book::STATUSES.each_with_object({}) do |status, hash|
        hash[status] = counts[status] || 0
      end
    end

    def deals_by_status
      counts = Deal.group(:status).count
      Deal.statuses.keys.each_with_object({}) do |status, hash|
        hash[status] = counts[status] || 0
      end
    end

    # =========================================================================
    # Top Rankings
    # =========================================================================

    def top_publishers_by_deal_count(limit = 5)
      Publisher
        .joins(:deals)
        .group("publishers.id")
        .order("COUNT(deals.id) DESC")
        .limit(limit)
        .count("deals.id")
        .map do |publisher_id, count|
          { publisher: Publisher.find(publisher_id), deal_count: count }
        end
    end

    def top_agents_by_deal_count(limit = 5)
      Agent
        .joins(:deals)
        .group("agents.id")
        .order("COUNT(deals.id) DESC")
        .limit(limit)
        .count("deals.id")
        .map do |agent_id, count|
          { agent: Agent.find(agent_id), deal_count: count }
        end
    end

    private

    # =========================================================================
    # Period Helpers
    # =========================================================================

    def period_range(period)
      start_method = PERIOD_METHODS[period]
      raise ArgumentError, "Unknown period: #{period}" unless start_method

      end_method = :"end_of_#{period}"
      Date.current.public_send(start_method)..Date.current.public_send(end_method)
    end

    def previous_period_range(period)
      case period
      when :month
        previous_start = Date.current.beginning_of_month - 1.month
        previous_start..previous_start.end_of_month
      when :quarter
        previous_start = Date.current.beginning_of_quarter - 3.months
        previous_start..previous_start.end_of_quarter
      when :year
        previous_start = Date.current.beginning_of_year - 1.year
        previous_start..previous_start.end_of_year
      else
        raise ArgumentError, "Unknown period: #{period}"
      end
    end

    def deals_in_period(period)
      Deal.where(offer_date: period_range(period))
    end

    def calculate_metric_for_range(metric, range)
      case metric
      when :deals_count
        Deal.where(offer_date: range).count
      when :total_advance
        Deal.where(offer_date: range).sum(:advance_amount).to_i
      else
        raise ArgumentError, "Unknown metric: #{metric}"
      end
    end
  end
end
