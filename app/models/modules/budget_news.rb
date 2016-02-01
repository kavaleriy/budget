class Modules::BudgetNews
  include Mongoid::Document

  validates :title,:news_text,:link,:img, presence: true
  validates :link, format: { with: /(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?/,
                             message: I18n.t('activerecord.attributes.invalid.link') }

  field :title, type: String
  field :news_text, type: String
  field :link, type: String
  field :img, type: String
  field :news_date, type: DateTime
end
