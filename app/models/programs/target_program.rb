class Programs::TargetProgram
  include Mongoid::Document

  PROGRAM_TYPE = 1
  SUBPROGRAM_TYPE = 2
  TASK_TYPE = 3


  field :title, type: String
  field :years, type: Hash
  field :p_id,type: String
  field :responsible,type: String
  field :kvkv,type: String # program code
  field :kfkv,type: String # functional code (branch)
  field :manager,type: String
  field :reason,type: String
  field :budget_sum, type: Hash
  field :objective, type: String
  field :tasks,type: Hash
  field :region_target_program,type: Hash

  has_many :sub_programs,class_name: 'Programs::TargetProgram',foreign_key: 'p_id'
  embeds_many :indicators,class_name: 'Programs::Indicator'
  embeds_many :tasks,class_name: 'Program::Task'

  scope :get_main_programs,-> {where(p_id: nil)}

  validates :title,:responsible,:manager,presence: true

  def init_default_budget_sum
    self.budget_sum = {
        general_fund: '',
        special_fund: '',
        sum: ''
    }
  end

  def self.import(file_path)
    workbook = XlsParser.get_workbook(file_path)
    worksheet = workbook[0]
    table_in_hash = XlsParser.get_table_hash(worksheet)
    binding.pry
  end

end
