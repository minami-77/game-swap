class Chat < ApplicationRecord
  has_many :messages

  # validates :last_message, presence: true
  validates :first_user_id, presence: true
  validates :second_user_id, presence: true
end
