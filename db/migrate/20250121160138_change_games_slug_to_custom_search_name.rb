class ChangeGamesSlugToCustomSearchName < ActiveRecord::Migration[7.1]
  def change
    remove_column :games, :slug, :string
    add_column :games, :search_name, :string
  end
end
