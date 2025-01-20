class Game < ApplicationRecord
  has_many :covers
  has_many :listings

  validates :igdb_id, presence: true, uniqueness: true
  validates :name, presence: true
end
