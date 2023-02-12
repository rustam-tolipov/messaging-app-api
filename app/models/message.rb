class Message < ApplicationRecord
  belongs_to :user

  validates :body, presence: true

  after_create_commit { broadcast_message }

  # get user name
  def current_user(user_id)
    User.find(user_id)
  end

  private

  def broadcast_message
    ActionCable.server.broadcast('MessagesChannel', {
                                   id:,
                                    body:,
                                    user_id:,
                                    user: 
                                 })
  end
end
