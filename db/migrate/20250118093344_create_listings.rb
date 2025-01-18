class CreateListings < ActiveRecord::Migration[7.1]
  def change
    create_table :listings do |t|
      t.string :title
      t.string :image_url
      t.float :price
      t.text :description
      t.integer :max
      t.text :game_info
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
