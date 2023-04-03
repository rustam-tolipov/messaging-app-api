class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.text :body
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end

# add_column reference to chat_room
# rails g migration AddChatRoomToMessages chat_room:references