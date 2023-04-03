module Api
  module V1
    class ChatRoomsController < ApplicationController
      before_action :set_chat_room, only: %i[ show update destroy ]
      before_action :authenticate_user!, only: %i[ index create update destroy ]
    
      def index
        @chat_rooms = ChatRoom.public_room
        @private_chat_rooms = ChatRoom.where("title LIKE ?", "%#{current_user.id}%").where(is_private: true)
        @direct_messages = []
        @allUsers = User.all

        @allUsers.each do |user|
          @private_chat_rooms.each do |chat_room|
            if chat_room.title.include? user.id.to_s
              next if user.id == current_user.id
              chat_room.title = user.username
              @direct_messages.push(chat_room)
            end
          end
        end

        @allChatRooms = @chat_rooms + @direct_messages

        render json: @allChatRooms, each_serializer: ChatRoomSerializer, status: :ok
      end
    
      def show
        @chat_room = ChatRoom.find(params[:id])
        
        if @chat_room.is_private
          if @chat_room.title.include? current_user.id.to_s
            @user = User.find(@chat_room.title.split("-").select { |id| id != current_user.id.to_s }.first)
            @chat_room.title = @user.username
          else
            render json: {
              message: "You are not authorized to view this chat room"
            }, status: :unauthorized
          end
        end

        render json: @chat_room
      end
    
      def create
        @chat_room = ChatRoom.new(chat_room_params)
    
        if @chat_room.save
          render json: @chat_room, status: :created
        else
          render json: @chat_room.errors, status: :unprocessable_entity
        end
      end
    
      def update
        if @chat_room.update(chat_room_params)
          render json: @chat_room
        else
          render json: @chat_room.errors, status: :unprocessable_entity
        end
      end
    
      def destroy
        @chat_room.destroy
      end
    
      private
        def set_chat_room
          @chat_room = ChatRoom.find(params[:id])
        end
    
        def chat_room_params
          params.permit(:title, :is_private, :image)
        end
    end    
  end
end