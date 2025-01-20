class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.string :name
      t.string :platforms
      t.string :slug
      t.text :summary
      t.string :url
      t.integer :cover_id
      t.integer :igdb_id

      t.timestamps
    end
  end
end
