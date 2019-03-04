class Budget::GovFiles::Income
  include Mongoid::Document

  field :koatuu, type: String
  field :month, type: Integer
  field :year, type: Integer

  field :koatuu, type: String
  field :fund_type, type: String
  field :income_code, type: String
  field :income_code_name, type: String
  field :budget_plan, type: Float
  field :budget_estimate, type: Float
  field :total_done, type: Float
  field :percent_done, type: Float

  belongs_to :town, foreign_key: :koatuu
end
