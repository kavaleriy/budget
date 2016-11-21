class Programs::TargetedProgram
  extend ProgramBudgetSum
  include Mongoid::Document
  include Mongoid::Timestamps

  PROGRAM_TYPE = 1
  SUBPROGRAM_TYPE = 2
  TASK_TYPE = 3

  before_save :calc_budget_sum

  field :main_manager,            type: String # головний розпорядник
  field :type_title,              type: String
  field :title,                   type: String
  field :p_id,                    type: String
  field :responsible,             type: String
  field :kpkvk,                   type: String # program code
  field :kfkvk,                   type: String # functional code (branch)
  field :manager,                 type: String # розпорядник
  field :reason,                  type: String # Підстава
  field :budget_sum,              type: Hash
  # TODO validate this field
  field :quoter,                  type: Integer #Тривалість
  field :objective,               type: String # ціль
  field :region_target_program,   type: Hash
  field :active,                  type: Boolean, default: true

  has_many :sub_programs, class_name: 'Programs::TargetedProgram',  foreign_key: 'p_id'
  has_many :indicators,   class_name: 'Programs::Indicator'
  has_many :tasks,        class_name: 'Programs::Task'

  belongs_to :town,       class_name: 'Town', index: true
  belongs_to :author,     class_name: 'User', index: true

  scope :get_main_programs, -> { where(p_id: nil) }
  # Get programs by town
  scope :by_town, -> (town) { where(town: town) }
  # Get active programs
  scope :by_active, -> { where(active: true) }

  validates :title, :responsible, :manager, :town, :author, presence: true

  mount_uploader :targeted_program_file, TargetedProgramUploader
  skip_callback :update, :before, :store_previous_model_for_targeted_program_file

  def init_default_budget_sum
    year = Date.today.year.to_s
    self.budget_sum = {
        year => {
            plan: {
                general_fund: 0.0,
                special_fund: 0.0,
                sum: 0.0
            }
            # fact: {
            #     general_fund: 0,
            #     special_fund: 0,
            #     sum: 0
            # }
        }
    }
  end

  def self.import(file_path)
    workbook = XlsParser.get_workbook(file_path)
    worksheet = workbook[0]
    program = create_program_by_xls(worksheet)

    unless workbook['Tasks'].nil?
      Programs::Task.create_tasks_by_xls(workbook['Tasks'], program)
    end

    unless workbook['Indicates'].nil?
      year = program.budget_sum.keys.first
      Programs::Indicator.create_indicators_by_xls(workbook['Indicates'], program)
    end

    program

  end

  def self.get_grouped_indicators(indicators)
    group_indicators = indicators.group_by{|f| f.group}
    group_indicators.transform_keys{|key|Programs::Indicator::set_indicator_group_name(key)}
  end

  def check_access(user)
    # this function check access to update or destroy document
    # get one parameter user model
    # return true if user admin
    # return true if user created this document
    # else return false
    user.is_admin? || self.owner.eql?(user)
  end

  def self.data_bar(taxonomy, year, type)
    # generates data for drawing bar
    # get:
    #   3 params:
    #     taxonomy
    #     year
    #     type ( fond, ktfk, ftfk_aaa, kvk, kekv, krk )
    # return:
    #   array with Hash { ktvk, kfk, title, amount }

    # TODO: Clear function code after finish coding
    # kfk_spr = codes_relations
    explainer = taxonomy.explanation[type]
    tree = taxonomy.get_tree([type.to_sym])

    result = []

    # Add item to array

    tree['children'].each do |item|
      key = item['key']
      result <<
      {
        kvk: key,
        # kvk: kfk_spr[key],
        title: explainer[key]['title'],
        amount: item['amount'][:fact][year.first]['0']['total']
      }
    end

    # Add Total at the end of array

    tree['amount'].each do |item|
      result <<
          {
              title: 'Всього',
              amount: item.last[year.first]['0']['total']
          }
    end
    result
  end

  def self.load_from_csv(file_name)

    # load data from CSV file
    # input csv file with 2 fields: ftvk code; kfk code
    # return (Hash): 'ftvk' => 'kfk'
    # or
    # empty Hash if error

    codes = {}
    CSV.foreach(file_name, headers: true, col_sep: ";") do |row|
      codes[row[0]] = row[1]
    end
    codes
  end

  # TODO: Now it's code nothing to do. Can be deleted
  # def self.codes_relations
  #
  #   # open to load file "db/ktvk_to_kfk.csv"
  #   # return (Hash): 'ftvk' => 'kfk'
  #   # or
  #   # nil if file cann't read
  #
  #   ktvk_to_kfk = self.load_from_csv 'db/ktvk_to_kfk.csv' if ktvk_to_kfk.nil?
  #   ktvk_to_kfk
  # end

  private

  def self.create_program_by_xls(sheet)
    unless sheet.nil?
      program_hash = XlsParser.get_table_hash(sheet).first
      program_year = program_hash["year"].to_s
      program_hash.except!("year")
      tmp = ProgramBudgetSum::ProgramBudgetSumHash.new
      tmp.sum_hash = program_hash
      budget_sum_hash = { program_year => tmp.sum_hash }
      program = self.new(program_hash)
      program.budget_sum = budget_sum_hash
      program

    end
  end

  def calc_budget_sum
    # function set budget sum by general and special fund
    # year = Date.today.year.to_s
    self.budget_sum.each do |key,year|
      general_plan_fund = year[:plan][:general_fund].to_f
      special_plan_fund = year[:plan][:special_fund].to_f
      year[:plan][:sum] = general_plan_fund + special_plan_fund

      # set budget fact sum if exist
      # unless budget_sum_by_year[:fact].nil?
      general_fact_sum = year[:fact][:general_fund].to_f
      special_fact_sum = year[:fact][:special_fund].to_f
      year[:fact][:sum] = general_fact_sum + special_fact_sum

      year[:differences][:general_fund] = general_fact_sum - general_plan_fund
      year[:differences][:special_fund] = special_fact_sum - special_plan_fund
      year[:differences][:sum] = year[:fact][:sum] - year[:plan][:sum]
    end

    # budget_sum_by_year = self.budget_sum[year]
    # set budget plan sum
    # else
    #   init_default_fact_sum(year)
    # end
  end
  #
  # def init_default_fact_sum(year)
  #   self.budget_sum[year][:fact] = {
  #       general_sum: 0.0,
  #       special_sum: 0.0,
  #       sum: 0.0
  #   }
  # end

  # Get array of years from programs
  # return array of string, example: [ "2016", "2015" ]
  # or
  # empty array if town programs does not has year
  def self.programs_years(programs)
    years = []
    programs.each { |p|
      p.budget_sum.keys.each { |y|
        years.include?(y) ? next : years << y
      }
    }
    years
  end

end
