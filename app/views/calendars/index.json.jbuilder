json.array!(@calendars) do |calendar|
  json.extract! calendar, :id, :dt_start, :dt_end, :title, :body
  json.url calendar_url(calendar, format: :json)
end
