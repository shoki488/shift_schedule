class AddShiftTypeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :shift_type, :string
  end
end
