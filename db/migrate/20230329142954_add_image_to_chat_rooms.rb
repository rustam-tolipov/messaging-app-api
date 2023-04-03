class AddImageToChatRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :chat_rooms, :image, :string
  end
end
