class CreatePlatforms < ActiveRecord::Migration[7.1]
  def change
    create_table :platforms do |t|
      t.integer :platform_id
      t.string :name
      t.string :slug

      t.timestamps
    end
  end
end
