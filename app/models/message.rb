class Message < ApplicationRecord
  acts_as_readable on: :created_at

  belongs_to :user

  validates :body, presence: true

  # before_save :set_time_zone

  private

  def set_time_zone
    Time.zone = 'Tashkent'
    self.created_at ||= Time.zone.now
    self.updated_at ||= Time.zone.now
  end
end