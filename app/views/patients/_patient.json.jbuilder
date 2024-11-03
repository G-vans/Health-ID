json.extract! patient, :id, :health_id, :patient_id, :name, :created_at, :updated_at
json.url patient_url(patient, format: :json)
