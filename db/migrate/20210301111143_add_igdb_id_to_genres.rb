class AddIgdbIdToGenres < ActiveRecord::Migration[6.0]
  def change
    add_column :genres, :igdb_id, :integer
  end
end
