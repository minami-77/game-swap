class AddRatingsToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :total_rating_count, :integer
    add_column :games, :total_rating, :real
  end
end
