class CreateLabResults < ActiveRecord::Migration[7.0]
  def change
    create_table :lab_results do |t|
      t.references :lab, null: false, foreign_key: { to_table: :companies }
      t.references :patient, null: false, foreign_key: true
      t.string :test_name, null: false
      t.string :result_value, null: false
      t.string :result_unit, null: false
      t.string :reference_range, null: false
      t.datetime :test_date, null: false
      t.text :notes
      
      t.timestamps
    end

    add_index :lab_results, :test_date
    add_index :lab_results, [:patient_id, :test_date]
  end
end
