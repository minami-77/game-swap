class Game < ApplicationRecord
  has_one :cover
  has_many :listings, dependent: :destroy

  validates :igdb_id, presence: true, uniqueness: true
  validates :name, presence: true

  before_save :set_search_name

  private

  def set_search_name
    self.search_name = name.gsub(/[^a-z0-9]/i, '').downcase
  end
end
