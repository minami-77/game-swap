class Platform < ApplicationRecord
  has_many :listings, dependent: :destroy

  validates :name, presence: true
  validates :platform_id, presence: true, uniqueness: true
end
