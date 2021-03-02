class AddEsrbIdToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :esrb_id, :integer
  end
end
