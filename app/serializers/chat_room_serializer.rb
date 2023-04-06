class ChatRoomSerializer < ActiveModel::Serializer
  attributes :id, :title, :is_private, :image, :user_id, :users_count, :last_message, :username, :unread_messages_count, :last_message_at, :members

  def user_id
    if object.is_private?
      object.get_user
    end
  end

  def users_count
    members.count
  end

  def image
    unless object.is_private?
      object.image
    else
      user = User.where(username: object.title).first
      if user
        user.avatar
      else
        object.image
      end
    end
  end

  def last_message
    unless object.messages.empty?
      object.messages.last.body
    end
  end

  def username 
    object.messages.last.user.username if object.messages.last
  end

  def unread_messages_count
    object.unread_messages(current_user)
  end

  def last_message_at
    object.messages.last.created_at if object.messages.last
  end

  def members
    object.users.ids
  end
end