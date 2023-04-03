class UsersChannel < ApplicationCable::Channel
  def subscribed

    stop_all_streams

    current_user = User.find_by(id: params[:current_user_id])

    stream_from "users_channel_#{current_user.id}"
  end

  def receive(data)
    case data['status']
    when 'private_room_created'
      ActionCable.server.broadcast("users_channel_#{current_user.id}", {
        status: data['status'],
        id: data['id'],
        title: data['title'],
        is_private: data['is_private'],
        image: data['image'],
        user_id: data['user_id'],
        users_count: data['users_count'],
      })
    when 'private_room_updated'
      ActionCable.server.broadcast("users_channel_#{current_user.id}", {
        status: data['status'],
        id: data['id'],
        title: data['title'],
        is_private: data['is_private'],
        image: data['image'],
        user_id: data['user_id'],
        users_count: data['users_count'],
      })
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
