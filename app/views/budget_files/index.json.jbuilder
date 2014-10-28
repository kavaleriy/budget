json.array!(@budget_files) do |budget_file|
  json.extract! budget_file, :id, :title, :file
  json.url budget_file_url(budget_file, format: :json)
end
