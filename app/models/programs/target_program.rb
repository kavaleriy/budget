class Programs::TargetProgram
  include Mongoid::Document

  field :kpkv, type: String      # program code
  field :kfkv, type: String      # functional code (branch)
  field :term_start, type: Integer
  field :term_end, type: Integer
  field :phases, type: Array
  field :amount_plan, type: Integer
  field :title, type: String
  field :targets, type: String
  field :tasks, type: Array
  field :expected_results, type: Array
  field :participants, type: Array
  field :description, type: String
  field :author, type: String

  field :description, type: String

  belongs_to :programs_town, :class_name => 'Programs::Town', autosave: true
  has_many :programs_indicators, :class_name => 'Programs::Indicators', autosave: true, :dependent => :destroy
  has_many :programs_expences, :class_name => 'Programs::Expences', autosave: true, :dependent => :destroy
  has_many :programs_attachments, :class_name => 'Programs::Attachment', autosave: true, :dependent => :destroy

  validates :title, presence: true
  validates :kpkv, :uniqueness => {:scope => :programs_town}

  def import row
    self.kpkv = row['kpkv'].to_s.rjust(7, '0')
    self.kfkv = row['kfkv'].to_s.rjust(4, '0')
    self.term_start = row['term_start'].to_i
    self.term_end = row['term_end'].to_i
    self.phases = row['phases'].split('/') || []
    self.amount_plan = row['amount_plan'].to_i
    self.title = row['title']
    self.targets = row['targets']
    self.tasks = row['tasks'].split('//')
    self.expected_results = row['expected_results'].split('//')
    self.participants = row['participants'].split('//')
    self.description = row['description']
  end

  def get_total_amount year
    amounts = {}
    amounts['amount_plan'] = self.amount_plan || 0
    amounts['amount_fact'] = 0
    expences = self.programs_expences.where( :year.lt => year)
    expences.each{|expence|
      amounts['amount_fact'] += expence['amount_fact'] || 0
    }
    amounts
  end

  def get_indicators
    indicators = {}
    self.programs_indicators.each{|indicator|
      group = indicator['group']
      name = indicator['indicator']
      year = indicator['year']
      indicators[group] = {} if indicators[group].nil?
      indicators[group][name] = {} if indicators[group][name].nil?
      indicators[group][name]['unit'] = indicator['unit']
      indicators[group][name]['years'] = {} if indicators[group][name]['years'].nil?
      indicators[group][name]['years'][year] = {}
      indicators[group][name]['years'][year]['amount_plan'] = indicator['amount_plan']
      indicators[group][name]['years'][year]['amount_fact'] = indicator['amount_fact']
      indicators[group][name]['years'][year]['description'] = indicator['description']
    }
    indicators
  end

end
