class ChangeDatatypeStartTimeAndEndTimeOfUsers < ActiveRecord::Migration[6.1]
  def change
    change_column :users, :end_time, :time
    change_column :users, :start_time, :time
  end
end
