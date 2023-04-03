class CreateUserStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :user_statuses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :chat_room, null: false, foreign_key: true
      t.datetime :last_read_at
      t.datetime :last_seen_at
      t.string :status

      t.timestamps
    end
  end
end
