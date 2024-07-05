class AddUserIdToOpenAi < ActiveRecord::Migration[6.1]
  def change
    add_reference :open_ais, :user, null: false, foreign_key: true
  end
end
