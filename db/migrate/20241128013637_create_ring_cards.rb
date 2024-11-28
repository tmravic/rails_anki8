class CreateRingCards < ActiveRecord::Migration[8.0]
  def change
    create_table :ring_cards do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :ring_number

      t.timestamps
    end
  end
end
