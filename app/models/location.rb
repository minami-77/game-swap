class Location < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :listings, through: :users

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
end
