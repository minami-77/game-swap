class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.datetime :last_message
      t.integer :first_user_id
      t.integer :second_user_id

      t.timestamps
    end
  end
end
