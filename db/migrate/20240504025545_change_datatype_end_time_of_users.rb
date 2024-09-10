class ChangeDatatypeEndTimeOfUsers < ActiveRecord::Migration[6.1]
  def up
    change_column :users, :end_time, 'integer USING CAST(end_time AS integer)'
  end

  def down
    change_column :users, :end_time, :string 
  end
end
