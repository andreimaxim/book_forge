class Note < ApplicationRecord
  # Associations
  belongs_to :notable, polymorphic: true

  # Validations
  validates :content, presence: true, length: { minimum: 2 }

  # Scopes
  scope :pinned, -> { where(pinned: true) }
  scope :by_date, ->(direction = :desc) { order(created_at: direction) }
  scope :pinned_first, -> { order(pinned: :desc, created_at: :desc) }

  # Instance methods
  def rendered_content
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        hard_wrap: true,
        no_styles: true,
        safe_links_only: true
      ),
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      highlight: true,
      no_intra_emphasis: true
    )

    raw_html = markdown.render(content || "")
    ActionController::Base.helpers.sanitize(
      raw_html,
      tags: %w[p br h1 h2 h3 h4 h5 h6 strong em a ul ol li blockquote pre code hr table thead tbody tr th td],
      attributes: %w[href title]
    )
  end

  def preview(length = 100)
    return "" if content.blank?
    content.truncate(length)
  end
end
