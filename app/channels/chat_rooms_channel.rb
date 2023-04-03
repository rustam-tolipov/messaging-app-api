class ChatRoomsChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams 
    
    stream_from "ChatRoomsChannel"
  end

  def receive(data)

    if data['status'] == 'created'
      
      ActionCable.server.broadcast("ChatRoomsChannel", {
        status: data['status'],
        id: data['id'],
        title: data['title'],
        is_private: data['is_private'],
        image: data['image'],
      })

    elsif data['status'] == 'updated'

      chat_room = ChatRoom.find_by(id: data['id'])

      if chat_room.update(title: data['title'], is_private: data['is_private'])
        action(data)
      end

    elsif data['status'] == 'deleted'
      chat_room = ChatRoom.find_by(id: data['id'])

      if chat_room.destroy
        action(data)
      end
    end
  end

  def action(data)
    ActionCable.server.broadcast("ChatRoomsChannel", {
                                  status: data['status'],
                                  id: data['id'],
                                  title: data['title'],
                                  is_private: data['is_private'],
                                })
  end

  def unsubscribed
    stop_all_streams
  end
end
