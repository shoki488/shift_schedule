class AddCalendarToShifts < ActiveRecord::Migration[6.1]
  def change
    add_column :shifts, :calendar, :date
  end
end
