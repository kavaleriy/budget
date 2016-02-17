class ExportBudget
  include Mongoid::Document
  scope :get_export_budget_by_town, -> (town) { where(:town => town) }
  has_one :calendar
  belongs_to :town

  validates :year,:title,:template,:town_id, presence: true
  validates :year, numericality: { only_integer: true }

  field :year, type: Integer
  field :title, type: String
  field :template, type: String
  field :town_id, type: String
end
