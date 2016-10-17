json.array!(@modules_banners) do |modules_banner|
  json.extract! modules_banner, :id, :title, :order_banner, :publish_on
  json.url modules_banner_url(modules_banner, format: :json)
end
