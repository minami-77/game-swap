class Platform < ApplicationRecord
  validates :name, presence: true
  validates :platform_id, presence: true, uniqueness: true
end
