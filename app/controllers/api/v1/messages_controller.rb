module Api
  module V1
    class MessagesController < ApplicationController
      before_action :set_message, only: %i[ show update destroy ]
      before_action :authenticate_user!, only: %i[ create update destroy mark_as_read ]
    
      def index
        @messages = Message.where(chat_room_id: params[:chat_room_id]).paginate(page: params[:page], per_page: params[:per_page]).order(created_at: :asc)

        render json: @messages
      end
    
      def show
        render json: @message
      end
    
      def create
        @message = Message.new(message_params)
        @message.user_id = current_user.id
        @message.chat_room_id = params[:chat_room_id]

        if @message.save
          render json: @message, status: :created
        else
          render json: @message.errors, status: :unprocessable_entity
        end
      end
    
      def update
        if @message.update(message_params)
          render json: @message
        else
          render json: @message.errors, status: :unprocessable_entity
        end
      end
    
      def destroy
        @message.destroy
      end
    
      private
        def set_message
          @message = Message.find(params[:id])
        end
    
        def message_params
          params.permit(:body, :user_id, :chat_room_id, :created_at, :updated_at)
        end
    end    
  end
end