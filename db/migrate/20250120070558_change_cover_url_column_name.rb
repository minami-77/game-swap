class ChangeCoverUrlColumnName < ActiveRecord::Migration[7.1]
  def change
    remove_column :covers, :cover_url, :string
    add_column :covers, :url, :string
  end
end
