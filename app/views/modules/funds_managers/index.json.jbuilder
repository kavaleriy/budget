json.array!(@funds_managers) do |modules_funds_manager|
  json.extract! modules_funds_manager, :id, :edrpou
  json.url modules_funds_manager_url(modules_funds_manager, format: :json)
end
