class AddGenresToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :genres, :string
  end
end
