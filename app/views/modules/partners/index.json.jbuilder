json.array!(@modules_partners) do |modules_partner|
  json.extract! modules_partner, :id, :name, :order_logo, :publish_on
  json.url modules_partner_url(modules_partner, format: :json)
end
