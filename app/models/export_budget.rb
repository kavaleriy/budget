class ExportBudget
  include Mongoid::Document
  has_one :calendar
  belongs_to :town

  validates :year,:title,:template,:town_id, presence: true
  validates :year,:town_id, numericality: { only_integer: true }

  field :year, type: Integer
  field :title, type: String
  field :template, type: String
  field :town_id, type: Integer
end
