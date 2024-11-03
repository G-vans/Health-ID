class CreatePatients < ActiveRecord::Migration[7.0]
  def change
    create_table :patients do |t|
      t.string :health_id
      t.string :patient_id
      t.string :name

      t.timestamps
    end
  end
end
