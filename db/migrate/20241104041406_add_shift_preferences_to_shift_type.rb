class AddShiftPreferencesToShiftType < ActiveRecord::Migration[7.0]
  def change
    add_column :shift_preferences, :shift_type, :string
  end
end
