class RenameClinetIdToClientIdInCompanies < ActiveRecord::Migration[7.0]
  def change
    rename_column :companies, :clinet_id, :client_id
  end
end
