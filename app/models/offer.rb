class Offer < ApplicationRecord
  belongs_to :listing
  belongs_to :user

  validates :listing, presence: true
  validates :user, presence: true

  # ----- TODO: DISCUSS VALIDATIONS -----
  # validates :price, presence: true
  # validates :price, numericality: { greater_than: 0 }
  # validates :comments, length: { maximum: 255 }
end
