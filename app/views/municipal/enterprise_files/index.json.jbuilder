json.array!(@municipal_enterprise_files) do |municipal_enterprise_file|
  json.extract! municipal_enterprise_file, :id
  json.url municipal_enterprise_file_url(municipal_enterprise_file, format: :json)
end
