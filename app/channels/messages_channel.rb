class MessagesChannel < ApplicationCable::Channel
include MessagesChannelHelper
  def subscribed
    stop_all_streams   
    @chat_room = ChatRoom.find(params[:id]) 
    current_user = User.find_by(id: params[:current_user_id])
    stream_from "messages_channel_#{params[:id]}"

    prevate_room_user_status = []
    @chat_room.users.each do |user|
      if user.username.present?
        prevate_room_user_status << {id: user.id, username: user.username, last_seen: user.last_seen}
      else
        user = User.find_by(id: user.id).where.not(id: current_user.id)
        prevate_room_user_status << {id: user.id, username: user.username, last_seen: user.last_seen}
      end
    end

    ActionCable.server.broadcast("messages_channel_#{params[:id]}", {
                                    status: "subscribed_to_#{params[:id]}",
                                    users_count: @chat_room.users.count,
                                    chat_room_users: prevate_room_user_status,
                                    is_private: @chat_room.is_private,
                                    title: @chat_room.title,
                                    image: @chat_room.image,
                                    is_member: @chat_room.users.include?(current_user),
  })

  @chat_room.messages.where.not(user_id: current_user.id).unread_by(current_user).each do |message|
    message.mark_as_read! :for => current_user
  end



  end

  def receive(data)
    chat_room = ChatRoom.find_by(id: data['chat_room_id'])

    case data['status']
    when 'created'
      message = Message.new(body: data['body'], user_id: data['user_id'], chat_room_id: data['chat_room_id'])

      if message.save

        message_created("messages_channel_#{data['chat_room_id']}", message)

        if chat_room.is_private
          chat_room.users.each do |user|
            if user.id != data['user_id'].to_i
              new_message("users_channel_#{user.id}", message)
            end
          end
        end

        new_message("ChatRoomsChannel", message)
      end
    when 'updated'
      message = Message.find_by(id: data['id'])

      if message.update(body: data['body'])
        action(data)
      end
    when 'deleted'
      message = Message.find_by(id: data['id'])

      if message.destroy
        action(data)
      end
    when 'typing'
      typing_user(data)
    when 'stopped_typing'
      typing_user(data)
    when 'joined'
      user = User.find_by(id: data['user_id'])

      unless chat_room.users.include?(user)
        chat_room.users << user

        joined_user("messages_channel_#{params[:id]}", chat_room)
      end
                                    
    when 'left_chat_room'
      user = User.find_by(id: data['user_id'])
      chat_room.users.delete(user)
      joined_user("messages_channel_#{params[:id]}", chat_room)
    else
      ActionCable.server.broadcast("messages_channel_#{params[:id]}", {
        status: "unknown",
      })
    end
  end

  def unsubscribed 
    stop_all_streams
    ActionCable.server.broadcast("messages_channel_#{params[:id]}", {
                                    status: "unsubscribed_from_#{params[:id]}",
                                                                })
  end
end
