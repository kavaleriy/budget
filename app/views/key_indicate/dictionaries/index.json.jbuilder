json.array!(@key_indicate_dictionaries) do |key_indicate_dictionary|
  json.extract! key_indicate_dictionary, :id
  json.url key_indicate_dictionary_url(key_indicate_dictionary, format: :json)
end
