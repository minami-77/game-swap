class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  belongs_to :location, optional: true
  has_many :listings, dependent: :destroy
  has_many :offers, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Active Storage
  has_one_attached :photo

  # Add any necessary validations
  validates :password, presence: true, on: :create
  validates :password, confirmation: true, allow_blank: true
  validates :password_confirmation, presence: true, if: -> { password.present? }

  # Geocoding
  # geocoded_by :location_address
  # after_validation :geocode, if: :location_changed?

  # def location_address
  #   location&.address
  # end

  # def location_address=(address)
  #   self.location = Location.find_or_create_by(address: address)
  # end
end
