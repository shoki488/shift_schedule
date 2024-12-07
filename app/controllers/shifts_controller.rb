class ShiftsController < ApplicationController
  protect_from_forgery
  before_action :set_users, only: [:new, :create]
  def index
    @shifts = Shift.all
    @users = User.all
    case params[:sort]
    when 'date_asc'
      @shifts = @shifts.order(calendar: :asc)
    when 'date_desc'
      @shifts = @shifts.order(calendar: :desc)
    end
  end

  def show
    @shift = Shift.find(params[:id])
  end

  def new
    @shift = Shift.new
    @users = @users.sort_by { |user| user == current_user ? 0 : 1 }
  end

  def create
    @shift = current_user.assigned_shifts.new(shift_params)
    @shift.creator = current_user.name
  
    if params[:password] == ENV['SHIFT_CREATION_PASSWORD']
      start_date = @shift.calendar.beginning_of_month
      end_date = @shift.calendar.end_of_month

      shift_preferences = ShiftPreference.includes(:user).
        where(date: start_date..end_date).
        group_by(&:user)

      @shift.content = OpenAi.create_shift(current_user, @shift.calendar, shift_preferences)

      if @shift.save
        redirect_to shift_path(@shift), notice: I18n.t('shift.success')
      else
        flash.now[:error] = I18n.t('shift.failure')
        render :new
      end
    else
      flash.now[:error] = I18n.t('shift.invalid_password')
      render :new
    end
  end

  def destroy
    @shift = Shift.includes(:favorites).find(params[:id])
    if current_user&.classification == "リーダー"
      if @shift.destroy
        redirect_to shifts_path, notice: I18n.t('shift.destroy')
      else
        redirect_to shifts_path, alert: I18n.t('shift.delete_error')
      end
    end
  end

  private

  def shift_params
    params.require(:shift).permit(:user_id, :content, :calendar, :creator)
  end

  def set_users
    @users = User.all
  end
end
