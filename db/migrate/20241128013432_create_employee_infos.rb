class CreateEmployeeInfos < ActiveRecord::Migration[8.0]
  def change
    create_table :employee_infos do |t|
      t.references :user, null: false, foreign_key: true
      t.string :department

      t.timestamps
    end
  end
end
