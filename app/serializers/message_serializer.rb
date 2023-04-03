class MessageSerializer < ActiveModel::Serializer
  attributes :id, :body, :user_id, :chat_room_id, :created_at, :avatar, :username

  def avatar
    if object.user.avatar.url.present?
      object.user.avatar.url
    else
      UserSerializer::DEFAULT_AVATAR
    end
  end

  def username
    object.user.username
  end
end
