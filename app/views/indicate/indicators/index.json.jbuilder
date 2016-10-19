json.array!(@indicate_indicators) do |indicate_indicator|
  json.extract! indicate_indicator, :id
  json.url indicate_indicator_url(indicate_indicator, format: :json)
end
