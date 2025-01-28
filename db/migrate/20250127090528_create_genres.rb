class CreateGenres < ActiveRecord::Migration[7.1]
  def change
    create_table :genres do |t|
      t.string :name
      t.integer :genre_id
      t.string :search_name

      t.timestamps
    end
  end
end
