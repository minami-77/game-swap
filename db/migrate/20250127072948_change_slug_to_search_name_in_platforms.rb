class ChangeSlugToSearchNameInPlatforms < ActiveRecord::Migration[7.1]
  def change
    remove_column :platforms, :slug, :string
    add_column :platforms, :search_name, :string
  end
end
