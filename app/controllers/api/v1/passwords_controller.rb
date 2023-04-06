module Api
  module V1
    class PasswordsController < Devise::PasswordsController
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        if resource.errors.empty?
          render json: { message: 'Password changed successfully' }, status: :ok
        else
          render json: { error: resource.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end
    end
  end
end