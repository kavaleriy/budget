class Programs::TargetProgram
  include Mongoid::Document

  PROGRAM_TYPE = 1
  SUBPROGRAM_TYPE = 2
  TASK_TYPE = 3

  field :type_title, type: String
  field :title, type: String
  field :years, type: Hash
  field :p_id,type: String
  field :responsible,type: String
  field :kpkvk,type: String # program code
  field :kfkvk,type: String # functional code (branch)
  field :manager,type: String
  field :reason,type: String
  field :budget_sum, type: Hash
  field :objective, type: String
  field :region_target_program,type: Hash

  has_many :sub_programs,class_name: 'Programs::TargetProgram',foreign_key: 'p_id'
  embeds_many :indicators,class_name: 'Programs::Indicator'
  embeds_many :tasks,class_name: 'Programs::Task'

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
    program = create_program_by_xls(worksheet)
    program.tasks = create_tasks_by_xls(workbook['Tasks'])
    program.indicators = create_indicators_by_xls(workbook['Indicates'])
    program
  end
  def self.get_grouped_indicators(indicators)
    group_indicators = indicators.group_by{|f| f.group}
    group_indicators.transform_keys{|key|set_indicator_group_name(key)}
  end

  def self.set_indicator_group_name(key)
    case key.to_i
      when Programs::Indicator::EXPENSES_TYPE then 'expense'
      when Programs::Indicator::PRODUCT_TYPE then 'product'
      when Programs::Indicator::EFECTIVE_TYPE then 'efective'
      when Programs::Indicator::QUALITY_TYPE then 'quality'
      else
        'other'
    end
  end

  private
  def self.create_program_by_xls(sheet)
    unless sheet.nil?
      program_hash = XlsParser.get_table_hash(sheet).first
      program_year = program_hash["year"].to_s
      budget_sum_hash = { program_year => {plan: {},
                                           fact: {
                                               general_sum: 0,
                                               special_sum: 0,
                                               sum: 0
                                           }
                                          }
                        }
      program_hash.except!("year")
      budget_sum_name_array = ["general_fund","special_fund","sum"]
      budget_sum_name_array.each do |name|
        budget_sum_hash[program_year][:plan].store(name,program_hash[name])
        program_hash.except!(name)
      end
      program =  self.new(program_hash)
      program.budget_sum = budget_sum_hash
      program

    end
  end

  def self.create_tasks_by_xls(sheet)
    unless sheet.nil?
      res_tasks = []
      tasks_hash = XlsParser.get_table_hash(sheet)
      tasks_hash.each do |task_hash|
        res_tasks << Programs::Task.create(task_hash)
      end

    end
  end

  def self.create_indicators_by_xls(sheet)
    unless sheet.nil?
      res_indicates = []
      indicates_hash = XlsParser.get_table_hash(sheet)
      indicates_hash.each do |indicate_hash|
        res_indicates << Programs::Indicator.create(indicate_hash)
      end
    end
  end

end
