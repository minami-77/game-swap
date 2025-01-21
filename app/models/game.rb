class Game < ApplicationRecord
  has_one :cover
  has_many :listings, dependent: :destroy

  validates :igdb_id, presence: true, uniqueness: true
  validates :name, presence: true
end
