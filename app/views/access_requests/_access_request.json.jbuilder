json.extract! access_request, :id, :patient_id, :company_id, :status, :created_at, :updated_at
json.url access_request_url(access_request, format: :json)
