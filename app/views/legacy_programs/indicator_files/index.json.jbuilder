json.array!(@programs_indicator_files) do |programs_indicator_file|
  json.extract! programs_indicator_file, :id
  json.url programs_indicator_file_url(programs_indicator_file, format: :json)
end
