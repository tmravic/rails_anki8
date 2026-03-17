class AddAuthlogicFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :persistence_token, :string
    add_index :users, :persistence_token, unique: true

    add_column :users, :login_count, :integer, default: 0, null: false
    add_column :users, :failed_login_count, :integer, default: 0, null: false
    add_column :users, :last_request_at, :datetime
    add_column :users, :current_login_at, :datetime
    add_column :users, :last_login_at, :datetime
    add_column :users, :current_login_ip, :string
    add_column :users, :last_login_ip, :string
  end
end
