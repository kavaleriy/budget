class ExportBudget
  include Mongoid::Document
  has_one :calendar
  belongs_to :town

  field :year, type: Integer
  field :title, type: String
  field :template, type: String
  field :town_id, type: String
end
