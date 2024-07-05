class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

    protected
  def configure_permitted_parameters 
    devise_parameter_sanitizer.permit(:sign_up, keys:  [:name, :classification, :working_time, :start_time, :end_time, :shift_type])

    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :classification, :shift_type, :start_time, :end_time])
  end  
end
