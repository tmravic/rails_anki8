class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.string :external_link
      t.datetime :date_of_birth
      t.references :employee_info, null: false, foreign_key: true

      t.timestamps
    end
  end
end
