class ExportBudget
  include Mongoid::Document
  # has_one :calendar
  belongs_to :town

  validates :year,:title,:town, presence: true
  validates :year, numericality: { only_integer: true }

  field :year, type: Integer
  field :title, type: String
  # field :template, type: String
  # field :town_id, type: String
  # field :header, type: String
  # field :footer, type: String
  field :content, type: String
end
