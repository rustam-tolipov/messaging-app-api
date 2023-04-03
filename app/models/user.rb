class User < ApplicationRecord
  acts_as_reader
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :messages, dependent: :destroy
  has_many :chat_room_users, dependent: :destroy
  has_many :chat_rooms, through: :chat_room_users

  validates :username, :email, presence: true
  validates :username, uniqueness: true, length: { minimum: 3, maximum: 50 }

  mount_uploader :avatar, ImageUploader
  
  scope :search, ->(query) { query.present? ? where("username ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?", "%#{query}%", "%#{query}%", "%#{query}%") : none }

  ONLINE_TIMEOUT = 5.seconds

  def online?
    JSON.parse($redis_onlines.get("user_#{id}"))["last_seen"]
  end

  def last_seen
    unless $redis_onlines.get("user_#{id}").nil?
      if online? > ONLINE_TIMEOUT.ago
        'Online'
      else
        online?
      end
    else
      "Offline"
    end
  end
end
