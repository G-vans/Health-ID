class CreateCredentialShares < ActiveRecord::Migration[7.0]
  def change
    create_table :credential_shares do |t|
      t.references :credential, null: false, foreign_key: true
      t.references :verifier, polymorphic: true, null: false
      t.datetime :expires_at, null: false
      t.datetime :access_granted_at, null: false
      t.datetime :revoked_at
      
      t.timestamps
    end

    add_index :credential_shares, :expires_at
    add_index :credential_shares, [:credential_id, :verifier_id, :verifier_type], 
              name: 'index_credential_shares_on_credential_and_verifier'
  end
end
