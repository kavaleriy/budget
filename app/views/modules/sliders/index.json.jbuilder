json.array!(@modules_sliders) do |modules_slider|
  json.extract! modules_slider, :id, :text, :img
  json.url modules_slider_url(modules_slider, format: :json)
end
