module ApplicationHelper
  def nav_link_class(path)
    base_classes = "px-3 py-2 rounded-md text-sm font-medium transition-colors"

    if current_page?(path)
      "#{base_classes} bg-gray-100 text-gray-900"
    else
      "#{base_classes} text-gray-600 hover:bg-gray-50 hover:text-gray-900"
    end
  end

  def mobile_nav_link_class(path)
    base_classes = "block px-3 py-2 rounded-md text-base font-medium transition-colors"

    if current_page?(path)
      "#{base_classes} bg-gray-100 text-gray-900"
    else
      "#{base_classes} text-gray-600 hover:bg-gray-50 hover:text-gray-900"
    end
  end
end
