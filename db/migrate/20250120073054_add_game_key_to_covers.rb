class AddGameKeyToCovers < ActiveRecord::Migration[7.1]
  def change
    add_reference :covers, :game, foreign_key: true
  end
end
