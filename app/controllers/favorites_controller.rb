class FavoritesController < ApplicationController
  def create
    @shift = Shift.find(params[:shift_id])
    current_user.favorites.create(shift: @shift)
    if @shift.save
      redirect_to favorite_user_path(current_user), notice: I18n.t('favorite.success')
    end
  end

  def destroy
    @shift = Shift.find(params[:shift_id])
    current_user.favorites.find_by(shift: @shift).destroy
    redirect_to shifts_path(@shift), notice: I18n.t('favorite.destroy')
  end
end
