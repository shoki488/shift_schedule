class AddShiftPreferenceToNames < ActiveRecord::Migration[7.0]
  def change
    add_column :shift_preferences, :name, :string
  end
end
