class CreateNotificationLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :notification_logs do |t|
      t.references :patient, null: false, foreign_key: true
      t.string :notification_type, null: false
      t.string :channel
      t.text :content
      t.datetime :sent_at
      t.json :metadata

      t.timestamps
    end

    add_index :notification_logs, [:patient_id, :sent_at]
    add_index :notification_logs, [:notification_type, :sent_at]
  end
end