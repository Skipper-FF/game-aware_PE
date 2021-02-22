class CreateGameInteractiveElements < ActiveRecord::Migration[6.0]
  def change
    create_table :game_interactive_elements do |t|
      t.references :game, null: false, foreign_key: true
      t.references :esrb_interactive_element, null: false, foreign_key: true

      t.timestamps
    end
  end
end
