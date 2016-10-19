class Currency
  include Mongoid::Document

  field :title, type: String
  field :short_title, type: String

  embeds_many :rates, class_name: 'CurrencyRate'
end
