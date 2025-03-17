class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.references :user, foreign_key: true
      t.boolean :published, default: false
      t.timestamps
    end
  end
end
