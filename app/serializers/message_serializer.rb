class MessageSerializer < ActiveModel::Serializer
  attributes :id, :body, :user_id, :user

  def user
    User.find(object.user_id)
  end
end
