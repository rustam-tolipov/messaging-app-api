class AddMessagesCountToChatRoom < ActiveRecord::Migration[7.0]
  def change
    add_column :chat_rooms, :messages_count, :integer, default: 0
  end
end
