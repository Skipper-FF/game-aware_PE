class CreateEsrbInteractiveElements < ActiveRecord::Migration[6.0]
  def change
    create_table :esrb_interactive_elements do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
