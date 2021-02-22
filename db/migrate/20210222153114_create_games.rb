class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.string :name
      t.text :description
      t.text :rating_summary
      t.references :esrb_rating_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
