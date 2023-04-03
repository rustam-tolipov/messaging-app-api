module MessagesChannelHelper
  def typing_user(data)
    ActionCable.server.broadcast("messages_channel_#{params[:id]}", {
                                    status: data['status'],
                                    user_id: data['user_id'],
                                    chat_room_id: data['chat_room_id'],
                                    username: data['username'],
                                    is_private: data['is_private'],
                                  })
  end

  def new_message(channel, message)
    ActionCable.server.broadcast("#{channel}", {
      status: "new_message",
      id: message.id,
      body: message.body,
      user_id: message.user_id,
      chat_room_id: message.chat_room_id,
      username: message.user.username,
      created_at: message.created_at,
                                  })
  end

  def message_created(channel, message)
    ActionCable.server.broadcast("#{channel}", {
      status: "created",
      id: message.id,
      body: message.body,
      user_id: message.user_id,
      chat_room_id: message.chat_room_id,
      username: message.user.username,
      created_at: message.created_at,
      avatar: message.user.avatar,
                                  })
  end

  def joined_user(channel, chat_room)
    ActionCable.server.broadcast(channel, {
    status: "subscribed_to_#{chat_room.id}",
    users_count: chat_room.users.count,
    chat_room_users: chat_room.users.map{|user| {id: user.id, username: user.username, last_seen: user.last_seen}},
    is_private: chat_room.is_private,
                                })
  end

  def action(data)
    ActionCable.server.broadcast("messages_channel_#{data['chat_room_id']}", {
                                    status: data['status'],
                                    id: data['id'],
                                    body: data['body'],
                                    user_id: data['user_id'],
                                    chat_room_id: data['chat_room_id'],
                                  })
  end
end
