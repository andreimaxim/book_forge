class Search
  ENTITY_TYPES = {
    "Author" => Author,
    "Publisher" => Publisher,
    "Agent" => Agent,
    "Prospect" => Prospect,
    "Book" => Book,
    "Deal" => Deal
  }.freeze

  # Display fields used to generate the highlight text for each entity type.
  DISPLAY_FIELDS = {
    "Author" => ->(record) { "#{record.first_name} #{record.last_name}" },
    "Publisher" => ->(record) { record.name },
    "Agent" => ->(record) { "#{record.first_name} #{record.last_name} (#{record.agency_name})" },
    "Prospect" => ->(record) { "#{record.first_name} #{record.last_name} - #{record.project_title}" },
    "Book" => ->(record) { "#{record.title}#{record.isbn.present? ? " (#{record.isbn})" : ""}" },
    "Deal" => ->(record) { "Deal: #{record.book&.title}" }
  }.freeze

  attr_reader :query, :entity_type, :limit

  def initialize(query, entity_type: nil, limit: 50)
    @query = query.to_s.strip
    @entity_type = entity_type
    @limit = limit
  end

  # Convenience class method for flat results
  def self.call(query, entity_type: nil, limit: 50)
    new(query, entity_type: entity_type, limit: limit).results
  end

  # Convenience class method for grouped results
  def self.call_grouped(query, entity_type: nil, limit: 50)
    new(query, entity_type: entity_type, limit: limit).grouped_results
  end

  def results
    return [] if query.blank?

    all_results = []

    searchable_types.each do |type_name, model_class|
      records = model_class.search(query).limit(limit)
      records.each do |record|
        all_results << build_result(type_name, record)
      end
    end

    all_results
      .sort_by { |r| -r[:relevance] }
      .first(limit)
  end

  def grouped_results
    results.group_by { |r| r[:type] }
  end

  private

  def searchable_types
    if entity_type.present? && ENTITY_TYPES.key?(entity_type)
      { entity_type => ENTITY_TYPES[entity_type] }
    else
      ENTITY_TYPES
    end
  end

  def build_result(type_name, record)
    display_text = DISPLAY_FIELDS[type_name].call(record)
    {
      type: type_name,
      record: record,
      relevance: compute_relevance(type_name, record, display_text),
      highlight: highlight_text(display_text)
    }
  end

  def compute_relevance(type_name, record, display_text)
    score = 1.0
    downcased_query = query.downcase
    downcased_text = display_text.to_s.downcase

    # Exact match on the display text gets highest score
    if downcased_text == downcased_query
      score += 10.0
    # Starts with query
    elsif downcased_text.start_with?(downcased_query)
      score += 5.0
    # Contains query
    elsif downcased_text.include?(downcased_query)
      score += 2.0
    end

    score
  end

  def highlight_text(text)
    return text if query.blank?

    escaped_query = Regexp.escape(query)
    text.to_s.gsub(/(#{escaped_query})/i, '<mark>\1</mark>')
  end
end
