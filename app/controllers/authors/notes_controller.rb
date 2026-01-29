class Authors::NotesController < ApplicationController
  include AuthorScoped

  def show
    @notes = @author.notes.order(created_at: :desc)
  end
end
