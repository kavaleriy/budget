json.array!(@currencies) do |currency|
  json.extract! currency, :id, :title, :short_title, :reates
  json.url currency_url(currency, format: :json)
end
