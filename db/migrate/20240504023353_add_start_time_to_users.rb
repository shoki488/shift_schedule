class AddStartTimeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :start_time, :string
    add_column :users, :end_time, :string
  end
end
