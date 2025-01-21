class Cover < ApplicationRecord
  belongs_to :game

  validates :cover_id, uniqueness: true, presence: true
  validates :url, presence: true
end
