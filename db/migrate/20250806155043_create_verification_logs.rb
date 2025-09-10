class CreateVerificationLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :verification_logs do |t|
      t.references :credential, null: false, foreign_key: true
      t.references :verifier, polymorphic: true, null: false
      t.string :verification_result, null: false
      t.datetime :verified_at, null: false
      t.string :ip_address
      t.string :user_agent
      t.text :additional_data
      
      t.timestamps
    end

    add_index :verification_logs, :verification_result
    add_index :verification_logs, :verified_at
  end
end
