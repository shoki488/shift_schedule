class Users::AccountsController < ApplicationController
  before_action :ensure_normal_user, only: [:show]
  def index; end

  def show
    @user = current_user
  end

  protected

  def ensure_normal_user
    if current_user.email == 'guest@example.com'
      redirect_to root_path, alert: I18n.t('users.registrations.guest_user_alert')
    end
  end
end
