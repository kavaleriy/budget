json.array!(@subscribers) do |subscriber|
  json.extract! subscriber, :id, :email
  json.url subscriber_url(subscriber, format: :json)
end
