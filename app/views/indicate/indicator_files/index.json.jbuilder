json.array!(@indicate_indicator_files) do |indicate_indicator_file|
  json.extract! indicate_indicator_file, :id
  json.url indicate_indicator_file_url(indicate_indicator_file, format: :json)
end
