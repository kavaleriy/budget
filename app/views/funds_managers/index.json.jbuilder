json.array!(@funds_managers) do |funds_manager|
  json.extract! funds_manager, :id, :edrpou
  json.url funds_manager_url(funds_manager, format: :json)
end
