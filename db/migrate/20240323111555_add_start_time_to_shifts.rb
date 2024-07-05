class AddStartTimeToShifts < ActiveRecord::Migration[6.1]
  def change
    add_column :shifts, :start_time, :datetime
    add_column :shifts, :end_time, :datetime
    add_column :shifts, :overtime_eligible, :boolean, default: false, null: false
    add_column :shifts, :user_id, :integer
  end
end
