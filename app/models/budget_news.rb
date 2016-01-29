class BudgetNews
  include Mongoid::Document

  field :title, type: String
  field :news_text, type: String
  field :link, type: String
  field :img, type: String
  field :news_date, type: DateTime
end
