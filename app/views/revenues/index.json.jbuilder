json.array!(@revenues) do |revenue|
  json.extract! revenue, :id, :file
  json.url revenue_url(revenue, format: :json)
end
