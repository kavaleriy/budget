json.array!(@timelines) do |timeline|
  json.extract! timeline, :id, :occured_at
  json.url timeline_url(timeline, format: :json)
end
