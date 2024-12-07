class AddShiftTypeToShifts < ActiveRecord::Migration[7.0]
  def change
    add_column :shifts, :shift_type, :string
  end
end
