class AddWovertimeToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :overtime, :integer
    add_column :users, :classification, :string
    add_column :users, :working_time, :integer
  end
end
