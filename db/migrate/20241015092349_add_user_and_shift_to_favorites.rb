class AddUserAndShiftToFavorites < ActiveRecord::Migration[7.0]
  def change
    add_reference :favorites, :user, null: false, foreign_key: true
    add_reference :favorites, :shift, null: false, foreign_key: true
  end
end
