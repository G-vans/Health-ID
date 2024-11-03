class CreateConnections < ActiveRecord::Migration[7.0]
  def change
    create_table :connections do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
