class CreateProbes < ActiveRecord::Migration[8.0]
  def change
    create_table :probes do |t|
      t.string :source, null: false
      t.integer :lookups, null: false, default: 0
      t.timestamps
    end
  end
end