class CreateGameContentDescriptors < ActiveRecord::Migration[6.0]
  def change
    create_table :game_content_descriptors do |t|
      t.references :game, null: false, foreign_key: true
      t.references :esrb_content_descriptor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
