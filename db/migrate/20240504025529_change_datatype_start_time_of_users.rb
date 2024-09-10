class ChangeDatatypeStartTimeOfUsers < ActiveRecord::Migration[6.1]
  def up
    change_column :users, :start_time, 'integer USING CAST(start_time AS integer)'
  end

  def down
    change_column :users, :start_time, :string
  end
end
