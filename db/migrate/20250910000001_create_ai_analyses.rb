class CreateAiAnalyses < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_analyses do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :analyzable, polymorphic: true, null: true
      t.integer :analysis_type, default: 0
      t.text :reasoning_output
      t.integer :risk_assessment, default: 1
      t.json :recommendations
      t.boolean :alert_sent, default: false
      t.datetime :alert_sent_at

      t.timestamps
    end

    add_index :ai_analyses, [:patient_id, :created_at]
    add_index :ai_analyses, [:risk_assessment, :alert_sent]
    add_index :ai_analyses, [:analyzable_type, :analyzable_id]
  end
end