json.array!(@budget_news) do |budget_news|
  json.extract! budget_news, :id, :title, :news_text, :link, :img, :news_date
  json.url budget_news_url(budget_news, format: :json)
end
