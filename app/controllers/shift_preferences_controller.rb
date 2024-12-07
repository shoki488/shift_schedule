class ShiftPreferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_leader, only: [:index]
  before_action :ensure_normal_user, only: [:show, :new]

  def index
    start_date = params.fetch(:start_date, Date.today).to_date
    end_date = start_date.end_of_month.end_of_week

    role_order = { "リーダー" => 1, "社員" => 2, "パート・アルバイト" => 3 }

    @shift_preferences = ShiftPreference.includes(:user).
      where(date: start_date.beginning_of_month.beginning_of_week..end_date).
      group_by(&:user).
      sort_by { |user, _| [role_order[user.classification] || 4, user.name] }
  end

  def show
    start_date = Date.today.beginning_of_month.beginning_of_week
    end_date = Date.today.end_of_month.end_of_week
    @shift_preferences = current_user.shift_preferences.where(date: start_date..end_date).group_by(&:date)
  end

  def new
    start_date = params.fetch(:start_date, Date.today).to_date
    end_date = start_date.end_of_month.end_of_week
    @shift_preferences = current_user.shift_preferences.where(date: start_date.beginning_of_month.beginning_of_week..end_date).index_by(&:date)
  end

  def edit
    start_date = Date.today.beginning_of_month.beginning_of_week
    end_date = Date.today.end_of_month.end_of_week
    @shift_preferences = current_user.shift_preferences.where(date: start_date..end_date).group_by(&:date)
  end

  def create
    preferences = shift_preferences_params[:shift_preferences]
    success = true

    ActiveRecord::Base.transaction do
      preferences.each do |pref|
        shift_preference = current_user.shift_preferences.find_or_initialize_by(date: pref[:date])

        if pref[:preference_type].present? || pref[:notes].present? || pref[:shift_type].present? || pref[:start_time].present? || pref[:end_time].present?
          shift_preference.assign_attributes(
            notes: pref[:notes],
            preference_type: pref[:preference_type],
            shift_type: pref[:shift_type],
            start_time: pref[:start_time],
            end_time: pref[:end_time]
          )
        else
          shift_preference.destroy if shift_preference.persisted?
          next
        end

        unless shift_preference.save
          success = false
          raise ActiveRecord::Rollback
        end
      end
    end

    if success
      render json: { success: true, redirect_url: shift_preference_path(current_user.id) }
    else
      render json: { success: false, redirect_url: new_shift_preference_path }, status: :unprocessable_entity
    end
  end

  private

  def shift_preferences_params
    params.permit(shift_preferences: [:date, :notes, :name, :preference_type, :shift_type, :start_time, :end_time])
  end

  def authorize_leader
    unless current_user.classification == "リーダー"
      redirect_to root_path, error: '権限がありません'
    end
  end

  protected

  def ensure_normal_user
    if current_user.email == 'guest@example.com' || current_user.name == 'ゲスト'
      redirect_to root_path, error: I18n.t('shift_preference.ban')
    end
  end
end
