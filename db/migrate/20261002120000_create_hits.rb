class CreateHits < ActiveRecord::Migration[8.0]
  def change
    create_table :hits do |t|
      t.string :verb, null: false
      t.string :note, null: false
      t.timestamps
    end
  end
end