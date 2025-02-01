class Offer < ApplicationRecord
  belongs_to :listing
  belongs_to :user
  has_many :reviews, dependent: :destroy

  validates :listing, presence: true
  validates :user, presence: true

  # Enum for status
  enum status: { pending: 0, accepted: 1, rejected: 2 }

  # ----- TODO: DISCUSS VALIDATIONS -----
  # validates :price, presence: true
  # validates :price, numericality: { greater_than: 0 }
  validates :comments, length: { maximum: 255 }
end
