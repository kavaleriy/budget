json.array!(@calendar_actions) do |calendar_action|
  json.extract! calendar_action, :id, :title, :description, :background, :icon, :type
  json.url calendar_action_url(calendar_action, format: :json)
end
