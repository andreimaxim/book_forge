module AuthorScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_author
  end

  private

  def set_author
    @author = Author.find(params[:author_id])
  end
end
