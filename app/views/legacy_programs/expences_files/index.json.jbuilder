json.array!(@programs_expences_files) do |programs_expences_file|
  json.extract! programs_expences_file, :id
  json.url programs_expences_file_url(programs_expences_file, format: :json)
end
