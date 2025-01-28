class AddPlatformToListings < ActiveRecord::Migration[7.1]
  def change
    add_reference :listings, :platform, foreign_key: true
  end
end
