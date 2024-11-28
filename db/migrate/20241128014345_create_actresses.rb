class CreateActresses < ActiveRecord::Migration[8.0]
  def change
    create_table :actresses do |t|
      t.string :name

      t.timestamps
    end
  end
end
