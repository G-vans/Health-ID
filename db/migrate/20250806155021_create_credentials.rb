class CreateCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :credentials do |t|
      t.references :issuer, polymorphic: true, null: false
      t.references :holder, null: false, foreign_key: { to_table: :patients }
      t.string :credential_type, null: false
      t.text :credential_data, null: false
      t.string :status, default: 'active', null: false
      t.datetime :issued_at, null: false
      t.datetime :expires_at
      t.string :signature, null: false
      
      t.timestamps
    end

    add_index :credentials, :credential_type
    add_index :credentials, :status
    add_index :credentials, [:holder_id, :status]
  end
end
