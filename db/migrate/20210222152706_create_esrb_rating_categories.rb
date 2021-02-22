class CreateEsrbRatingCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :esrb_rating_categories do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
