class RemoveWorkingTimeFromUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :working_time, :integer
  end
end
