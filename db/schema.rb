# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_08_06_155043) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_requests", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "company_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_access_requests_on_company_id"
    t.index ["patient_id"], name: "index_access_requests_on_patient_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "tax_id"
    t.string "client_id"
    t.string "client_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_companies_on_email", unique: true
    t.index ["reset_password_token"], name: "index_companies_on_reset_password_token", unique: true
  end

  create_table "connections", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "company_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_connections_on_company_id"
    t.index ["patient_id"], name: "index_connections_on_patient_id"
  end

  create_table "credential_shares", force: :cascade do |t|
    t.bigint "credential_id", null: false
    t.string "verifier_type", null: false
    t.bigint "verifier_id", null: false
    t.datetime "expires_at", null: false
    t.datetime "access_granted_at", null: false
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credential_id", "verifier_id", "verifier_type"], name: "index_credential_shares_on_credential_and_verifier"
    t.index ["credential_id"], name: "index_credential_shares_on_credential_id"
    t.index ["expires_at"], name: "index_credential_shares_on_expires_at"
    t.index ["verifier_type", "verifier_id"], name: "index_credential_shares_on_verifier"
  end

  create_table "credentials", force: :cascade do |t|
    t.string "issuer_type", null: false
    t.bigint "issuer_id", null: false
    t.bigint "holder_id", null: false
    t.string "credential_type", null: false
    t.text "credential_data", null: false
    t.string "status", default: "active", null: false
    t.datetime "issued_at", null: false
    t.datetime "expires_at"
    t.string "signature", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credential_type"], name: "index_credentials_on_credential_type"
    t.index ["holder_id", "status"], name: "index_credentials_on_holder_id_and_status"
    t.index ["holder_id"], name: "index_credentials_on_holder_id"
    t.index ["issuer_type", "issuer_id"], name: "index_credentials_on_issuer"
    t.index ["status"], name: "index_credentials_on_status"
  end

  create_table "lab_results", force: :cascade do |t|
    t.bigint "lab_id", null: false
    t.bigint "patient_id", null: false
    t.string "test_name", null: false
    t.string "result_value", null: false
    t.string "result_unit", null: false
    t.string "reference_range", null: false
    t.datetime "test_date", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lab_id"], name: "index_lab_results_on_lab_id"
    t.index ["patient_id", "test_date"], name: "index_lab_results_on_patient_id_and_test_date"
    t.index ["patient_id"], name: "index_lab_results_on_patient_id"
    t.index ["test_date"], name: "index_lab_results_on_test_date"
  end

  create_table "patients", force: :cascade do |t|
    t.string "health_id"
    t.string "patient_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_patients_on_email", unique: true
    t.index ["reset_password_token"], name: "index_patients_on_reset_password_token", unique: true
  end

  create_table "verification_logs", force: :cascade do |t|
    t.bigint "credential_id", null: false
    t.string "verifier_type", null: false
    t.bigint "verifier_id", null: false
    t.string "verification_result", null: false
    t.datetime "verified_at", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.text "additional_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credential_id"], name: "index_verification_logs_on_credential_id"
    t.index ["verification_result"], name: "index_verification_logs_on_verification_result"
    t.index ["verified_at"], name: "index_verification_logs_on_verified_at"
    t.index ["verifier_type", "verifier_id"], name: "index_verification_logs_on_verifier"
  end

  add_foreign_key "access_requests", "companies"
  add_foreign_key "access_requests", "patients"
  add_foreign_key "connections", "companies"
  add_foreign_key "connections", "patients"
  add_foreign_key "credential_shares", "credentials"
  add_foreign_key "credentials", "patients", column: "holder_id"
  add_foreign_key "lab_results", "companies", column: "lab_id"
  add_foreign_key "lab_results", "patients"
  add_foreign_key "verification_logs", "credentials"
end
