json.array!(@municipal_guide_filters) do |municipal_guide_filter|
  json.extract! municipal_guide_filter, :id, :type_file, :type_enterprise
  json.url municipal_guide_filter_url(municipal_guide_filter, format: :json)
end
