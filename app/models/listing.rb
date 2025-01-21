class Listing < ApplicationRecord
  belongs_to :user
  belongs_to :game
  has_many :offers, dependent: :destroy

  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
  validates :max, presence: true, numericality: { greater_than: 0 }
end
