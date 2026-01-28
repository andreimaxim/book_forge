class DesignSystemTestController < ApplicationController
  def flash_test
    flash.now[:notice] = "This is a test notice"
  end

  def form_test
    @test_form = TestFormObject.new
  end

  def form_submit
    @test_form = TestFormObject.new(test_form_params)

    if @test_form.valid?
      flash[:notice] = "Form submitted successfully"
      redirect_to design_system_test_form_path
    else
      render :form_test, status: :unprocessable_entity
    end
  end

  def button_submit
    # Simulate a slow operation
    sleep 1
    flash[:notice] = "Action completed successfully"
    redirect_to design_system_test_button_path
  end

  def button_test
  end

  private

  def test_form_params
    params.require(:test_form_object).permit(:name, :email)
  end

  # Simple form object for testing validation
  class TestFormObject
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :name, :email

    validates :name, presence: true, length: { minimum: 2 }
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  end
end
