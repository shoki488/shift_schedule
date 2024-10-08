class UsersController < ApplicationController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def index
    @user = current_user if user_signed_in?
  end
    
  def new
    @user = User.new
    @user.start_time = Time.current 
    @user.end_time = Time.current + 1.hour
  end
    
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      redirect_to @user 
    else
      render 'new'
    end
  end
    
  def show
    @user = User.find(params[:id])
  end
    
  def update
  end

  def edit
    @user = current_user
  end

  def destroy
  end
      
  def account
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :working_time, :start_time, :end_time, :shift_type)
  end

  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:classification, :shift_type, :start_time, :end_time])
    devise_parameter_sanitizer.permit(:account_update, keys: [:classification, :shift_type, :start_time, :end_time])
  end
end
