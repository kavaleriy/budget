class ExportBudget
  include Mongoid::Document
  has_one :calendar
  belongs_to :town, autosave: true

  field :year, type: Integer
  field :title, type: String
  field :template, type: String
end
