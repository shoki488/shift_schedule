class ShiftsController < ApplicationController
  protect_from_forgery
  before_action :set_users, only: [:new, :create]
  def index
    @shifts = Shift.all
    @users = User.all
  end

  def show
    @shift = Shift.find(params[:id])
  end
  
  def new
    @shift = Shift.new
    @users = @users.sort_by { |user| user == current_user ? 0 : 1 }
  end

  def create
    @shift = current_user.shifts.new(shift_params)
    @shift.creator = User.find(@shift.user_id).name
    if params[:password] == ENV['SHIFT_CREATION_PASSWORD']
      if @shift.save 
        shift_content = OpenAi.create_shift(current_user)
        @shift.update(content: shift_content)
        redirect_to shift_path(@shift), notice: I18n.t('shifts.create.success')
      else
        flash.now[:alert] = I18n.t('shifts.create.failure')
        render :new
      end
    else
      flash.now[:alert] = I18n.t('shifts.create.invalid_password')
      render :new
    end
  end
      
  def destroy
    @shift = Shift.find(params[:id])
    @shift.destroy
    flash[:notice] = I18n.t('shift.destroy')
    redirect_to shifts_path
  end

  private

  def shift_params
    params.require(:shift).permit(:user_id, :content, :calendar, :creator)
  end

  def set_users
    @users = User.all
  end
end
