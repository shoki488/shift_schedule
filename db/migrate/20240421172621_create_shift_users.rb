class CreateShiftUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :shift_users do |t|

      t.timestamps
    end
  end
end
