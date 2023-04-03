class AddUsersToChatRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :chat_rooms, :users, :text
  end
end
