class Listing < ApplicationRecord
  has_many_attached :photos
  belongs_to :user
  belongs_to :game
  belongs_to :platform
  has_many :offers, dependent: :destroy

  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :max, presence: true, numericality: { greater_than: 0 }
  validate :photo_limit

  def photo_limit
    if photos.count > 4
      errors.add(:photos, "You can only upload a maximum of 4 photos")
    end
  end
end
