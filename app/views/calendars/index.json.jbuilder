json.array!(@calendars) do |calendar|
  json.extract! calendar, :id
  json.url calendar_url(calendar, format: :json)
end
