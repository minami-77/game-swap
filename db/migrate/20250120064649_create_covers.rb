class CreateCovers < ActiveRecord::Migration[7.1]
  def change
    create_table :covers do |t|
      t.integer :cover_id
      t.string :cover_url

      t.timestamps
    end
  end
end
