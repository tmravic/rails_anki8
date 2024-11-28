class CreateMovies < ActiveRecord::Migration[8.0]
  def change
    create_table :movies do |t|
      t.string :title
      t.integer :year
      t.references :actress, null: false, foreign_key: true

      t.timestamps
    end
  end
end
