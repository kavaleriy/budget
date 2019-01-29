json.array!(@properting_properties) do |properting_property|
  json.extract! properting_property, :id, :title, :koatuu, :district, :street, :description, :amount, :coordinates
  json.url properting_property_url(properting_property, format: :json)
end
