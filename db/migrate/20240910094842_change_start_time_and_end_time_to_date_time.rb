class ChangeStartTimeAndEndTimeToDateTime < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      ALTER TABLE users
      ALTER COLUMN start_time TYPE time USING to_timestamp(start_time)::time,
      ALTER COLUMN end_time TYPE time USING to_timestamp(end_time)::time
    SQL
  end

  def down
    change_column :users, :start_time, :integer
    change_column :users, :end_time, :integer
  end
end
