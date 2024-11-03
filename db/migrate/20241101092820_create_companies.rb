class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :tax_id
      t.string :clinet_id
      t.string :client_secret

      t.timestamps
    end
  end
end
