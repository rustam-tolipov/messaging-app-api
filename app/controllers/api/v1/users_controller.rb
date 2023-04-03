module Api
  module V1
    class UsersController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      before_action :authenticate_user!, only: [:me, :show, :update, :follow, :unfollow, :following, :followers]
      before_action :set_user, only: [:update, :destroy, :follow, :unfollow, :followers, :following, :user_posts]
      before_action :set_user_by_username, only: [:show_by_username]

      def index
        @users = User.all
        render json: @users, each_serializer: UserSerializer, status: :ok
      end

      def me
        render json: current_user, serializer: UserSerializer, status: :ok
      end

      def show
        @user = User.find(params[:id])

        if @user.id != current_user.id
          @chat_room = ChatRoom.find_by(title: "#{current_user.id}-#{params[:id]}")
          if @chat_room.nil? 
            @chat_room = ChatRoom.find_by(title: "#{params[:id]}-#{current_user.id}")
            if @chat_room.nil?
              @chat_room = ChatRoom.create(title: "#{current_user.id}-#{params[:id]}", is_private: true)
              
              if @chat_room.save
                ActionCable.server.broadcast("users_channel_#{current_user.id}", {
                status: "private_room_created",
                id: @chat_room.id,
                title: "#{current_user.username} - #{@user.username}",
                is_private: true,
                })

                ActionCable.server.broadcast("users_channel_#{params[:id]}", {
                status: "private_room_created",
                id: @chat_room.id,
                title: "#{current_user.username} - #{@user.username}",
                is_private: true,
                })
              end
            end
          end
        end

        if @user.id != current_user.id
          @private_chat_room = ChatRoom.find_by(title: "#{current_user.id}-#{params[:id]}")
          if @private_chat_room.nil?
            @private_chat_room = ChatRoom.find_by(title: "#{params[:id]}-#{current_user.id}")
          end
        end

        if @private_chat_room
          @private_chat_room.users << current_user unless @private_chat_room.users.include? current_user
          @private_chat_room.users << @user unless @private_chat_room.users.include? @user
        end

        render json: @private_chat_room
      end

      def user_of_chat_room
        @user = User.find(params[:id])
        render json: @user, serializer: UserSerializer, status: :ok
      end

      def show_by_username
        if @user
          render json: @user, serializer: UserSerializer, status: :ok
        else
          render json: {
            message: "User not found"
          }, status: :not_found
        end
      end

      # Get /users/1/posts
      def user_posts
        @posts = @user.posts.all.order(created_at: :desc)
        render json: @posts, each_serializer: PostSerializer, status: :ok
      end

      def search
        @users = User.search(params[:username])
        render json: @users, each_serializer: UserSerializer, status: :ok
      end

      def update
        if @user.update(user_params)
          render json: @user, serializer: UserSerializer, status: :ok
        else
          render_error(@user, :unprocessable_entity)
        end
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def set_user_by_username
        @user = User.find_by(username: params[:username])
      end

      def user_params
        params.permit(:id, :first_name, :last_name, :email, :avatar, :username, :bio)
      end

      def not_found
        render json: { error: 'Not Found' }, status: :not_found
      end

      # Render error message
      def render_error(object, status)
        render json: {
          errors: object.errors.full_messages
        }, status: status
      end
    end
  end
end
