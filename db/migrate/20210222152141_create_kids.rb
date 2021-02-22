class CreateKids < ActiveRecord::Migration[6.0]
  def change
    create_table :kids do |t|
      t.string :name
      t.date :birthdate
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
