class Message < ApplicationRecord
  acts_as_readable on: :created_at

  belongs_to :user

  validates :body, presence: true
end