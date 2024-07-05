class AddContentToShifts < ActiveRecord::Migration[6.1]
  def change
    add_column :shifts, :content, :text
  end
end
