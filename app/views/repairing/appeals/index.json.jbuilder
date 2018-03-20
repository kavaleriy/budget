json.array!(@repairing_appeals) do |repairing_appeal|
  json.extract! repairing_appeal, :id, :text, :approved, :full_name, :phone, :address, :user_consent
  json.url repairing_appeal_url(repairing_appeal, format: :json)
end
