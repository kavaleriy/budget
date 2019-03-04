class Budget::GovFiles::Expense
  include Mongoid::Document
  
  field :koatuu, type: String
  field :month, type: Integer
  field :year, type: Integer

  field :fund_type, type: String
  field :program_code, type: String
  field :program_code_name, type: String
  field :function_code, type: String
  field :function_code_name, type: String
  field :economic_code, type: String
  field :economic_code_name, type: String
  field :budget_plan, type: Float
  field :budget_estimate, type: Float
  field :total_done, type: Float
  field :percent_done, type: Float
  field :done_special_fund, type: Float
  field :done_service, type: String
  field :done_other, type: String
  field :total_bank_account, type: String
  field :bank_special_fund, type: String
  field :bank_service, type: String
  field :bank_other, type: String

  belongs_to :town, foreign_key: :koatuu

  validates :koatuu, :program_code, 
    :program_code_name, :function_code, 
    :function_code_name, :economic_code, 
    :budget_plan, 
    :budget_estimate, :total_done, 
    presence: true
end
