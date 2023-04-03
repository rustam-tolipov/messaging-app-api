class ChatRoom < ApplicationRecord
  belongs_to :user1, class_name: 'User', foreign_key: 'user1_id', optional: true
  belongs_to :user2, class_name: 'User', foreign_key: 'user2_id', optional: true

  has_many :messages, dependent: :destroy
  has_many :chat_room_users, dependent: :destroy
  has_many :users, through: :chat_room_users, dependent: :destroy

  validates :title, presence: true, uniqueness: true

  mount_uploader :image, ImageUploader
  
  scope :public_room, -> { where(is_private: false)}
  
  def unread_messages(user_id)
    messages = Message.where(chat_room_id: self.id)
    messages.where.not(user_id: user_id).unread_by(user_id).count
  end

  def private_room?
    self.is_private == true
  end

  def get_chat_room_users
    if self.private_room?
      user = User.where(username: self.title).first
      return [{id: user.id, username: user.username}]
    else
      users = self.users
      users_array = []
      users.each do |user|
        users_array << {id: user.id, username: user.username}
      end
      return users_array
    end
  end

  def get_user
    if self.private_room?
      if User.where(username: self.title).first
        user = User.where(username: self.title).first
        return user.id
      end
    end
  end
end
