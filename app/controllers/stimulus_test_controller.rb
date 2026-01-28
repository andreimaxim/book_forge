class StimulusTestController < ApplicationController
  def form_validation
  end

  def form_validation_submit
    @submitted = true
    render :form_validation
  end

  def auto_save
  end

  def auto_save_submit
    head :ok
  end

  def dropdown
  end

  def clipboard
  end

  def character_count
  end

  def filter
    @genre = params[:genre]
  end

  def sortable
  end

  def sortable_update
    head :ok
  end

  def toast
  end
end
