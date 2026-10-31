class CreateAdminAuth < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_users do |t|
      t.string :email, null: false
      t.string :encrypted_password, null: false, default: ""

      t.integer :sign_in_count, null: false, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      t.integer :failed_attempts, null: false, default: 0
      t.datetime :locked_at

      t.timestamps null: false

      t.index :email, unique: true
    end

    create_table :roles do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps

      t.index :name, unique: true
    end

    create_table :admin_user_roles do |t|
      t.references :admin_user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true

      t.timestamps

      t.index [ :admin_user_id, :role_id ], unique: true
    end

    create_table :jwt_denylist do |t|
      t.string :jti, null: false
      t.datetime :exp, null: false

      t.timestamps null: false

      t.index :jti, unique: true
    end
  end
end
