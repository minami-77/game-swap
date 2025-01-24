class AddGameRefToListings < ActiveRecord::Migration[7.1]
  def change
    add_reference :listings, :game, foreign_key: true
  end
end
