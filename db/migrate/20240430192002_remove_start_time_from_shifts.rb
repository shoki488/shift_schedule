class RemoveStartTimeFromShifts < ActiveRecord::Migration[6.1]
  def change
    remove_column :shifts, :start_time, :datetime
    remove_column :shifts, :end_time, :datetime
  end
end
