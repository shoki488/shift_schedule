class AddCreatorNameToShifts < ActiveRecord::Migration[6.1]
  def change
    add_column :shifts, :creator, :string
  end
end
