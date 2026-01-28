module UiHelper
  def primary_button(text, options = {})
    url = options.delete(:url) || "#"
    css_classes = "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"

    link_to(text, url, class: css_classes, **options)
  end

  def secondary_button(text, options = {})
    url = options.delete(:url) || "#"
    css_classes = "inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md shadow-sm text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors"

    link_to(text, url, class: css_classes, **options)
  end

  def danger_button(text, options = {})
    url = options.delete(:url) || "#"
    confirm_message = options.delete(:confirm)
    css_classes = "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 transition-colors"

    html_options = { class: css_classes, **options }
    html_options[:data] = (html_options[:data] || {}).merge(turbo_confirm: confirm_message) if confirm_message

    link_to(text, url, html_options)
  end

  def form_field(form, field, options = {})
    label_text = options.delete(:label) || field.to_s.humanize
    input_type = options.delete(:type) || :text_field

    object = form.object
    errors = object&.errors&.[](field) || []
    has_errors = errors.any?

    label_classes = "block text-sm font-medium text-gray-700"
    input_classes = "mt-1 block w-full rounded-md shadow-sm sm:text-sm"
    input_classes += has_errors ? " border-red-300 focus:border-red-500 focus:ring-red-500" : " border-gray-300 focus:border-blue-500 focus:ring-blue-500"
    error_classes = "mt-1 text-sm text-red-600"

    content_tag(:div, class: "mb-4") do
      label_html = form.label(field, label_text, class: label_classes)
      input_html = form.send(input_type, field, class: input_classes, **options)
      error_html = has_errors ? content_tag(:p, errors.first, class: error_classes) : "".html_safe

      label_html + input_html + error_html
    end
  end

  def card(title: nil, &block)
    card_classes = "bg-white rounded-lg shadow overflow-hidden"
    header_classes = "px-4 py-5 sm:px-6 border-b border-gray-200"
    title_classes = "text-lg font-medium leading-6 text-gray-900"
    body_classes = "px-4 py-5 sm:p-6"

    content_tag(:div, class: card_classes) do
      header_html = title ? content_tag(:div, content_tag(:h3, title, class: title_classes), class: header_classes) : "".html_safe
      body_html = content_tag(:div, capture(&block), class: body_classes)

      header_html + body_html
    end
  end

  def empty_state(icon:, message:, action: nil)
    container_classes = "text-center py-12"
    icon_classes = "mx-auto h-12 w-12 text-gray-400"
    message_classes = "mt-2 text-sm text-gray-500"

    content_tag(:div, class: container_classes) do
      icon_html = empty_state_icon(icon, icon_classes)
      message_html = content_tag(:p, message, class: message_classes)
      action_html = action ? content_tag(:div, action, class: "mt-6") : "".html_safe

      icon_html + message_html + action_html
    end
  end

  def badge(text, status:)
    colors = badge_colors_for_status(status)
    css_classes = "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{colors}"

    content_tag(:span, text, class: css_classes)
  end

  private

  def badge_colors_for_status(status)
    case status.to_sym
    when :active, :success, :published, :signed
      "bg-green-100 text-green-800"
    when :inactive, :archived, :completed
      "bg-gray-100 text-gray-800"
    when :pending, :draft, :negotiating, :under_review
      "bg-yellow-100 text-yellow-800"
    when :error, :danger, :terminated, :declined
      "bg-red-100 text-red-800"
    when :info, :new, :submitted
      "bg-blue-100 text-blue-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  def empty_state_icon(icon_name, css_classes)
    icons = {
      "inbox" => '<svg class="%s" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" /></svg>',
      "document" => '<svg class="%s" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg>',
      "users" => '<svg class="%s" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" /></svg>',
      "folder" => '<svg class="%s" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z" /></svg>'
    }

    svg = icons[icon_name] || icons["inbox"]
    (svg % css_classes).html_safe
  end
end
