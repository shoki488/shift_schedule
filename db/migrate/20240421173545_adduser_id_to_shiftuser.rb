class AdduserIdToShiftuser < ActiveRecord::Migration[6.1]
  def change
    add_column :shift_users, :user_id, :integer
    add_column :shift_users, :shift_id, :integer
  end
end
