class AddCoverUrlToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :cover_url, :string
  end
end
