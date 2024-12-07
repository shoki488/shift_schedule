class CreateShiftPreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :shift_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.time :start_time
      t.time :end_time
      t.string :preference_type
      t.text :notes

      t.timestamps
    end
  end
end
