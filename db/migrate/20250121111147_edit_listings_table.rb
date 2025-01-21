class EditListingsTable < ActiveRecord::Migration[7.1]
  def change
    remove_column :listings, :title, :string
    remove_column :listings, :game_info, :text
    remove_column :listings, :image_url, :string
  end
end
