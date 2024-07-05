class ChangeDatatypeStartTimeOfUsers < ActiveRecord::Migration[6.1]
  def change
    change_column :users, :start_time, :integer
  end
end
