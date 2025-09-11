class CreateTravelAdvisories < ActiveRecord::Migration[7.0]
  def change
    create_table :travel_advisories do |t|
      t.references :patient, null: false, foreign_key: true
      t.string :destination, null: false
      t.date :departure_date, null: false
      t.json :health_risks
      t.json :preparations
      t.json :emergency_contacts

      t.timestamps
    end

    add_index :travel_advisories, [:patient_id, :departure_date]
    add_index :travel_advisories, [:destination, :departure_date]
  end
end