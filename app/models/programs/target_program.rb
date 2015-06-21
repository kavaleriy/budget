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
  has_many :programs_indicator_files, :class_name => 'Programs::IndicatorFile', autosave: true, :dependent => :destroy
  has_many :programs_expences, :class_name => 'Programs::Expences', autosave: true, :dependent => :destroy

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
    self.programs_indicator_files.each{|file|
      file.rows.each{|row|
        group = row['group']
        indicator = row['indicator']
        year = row['year']
        indicators[group] = {} if indicators[group].nil?
        indicators[group][indicator] = {} if indicators[group][indicator].nil?
        indicators[group][indicator]['unit'] = row['unit']
        indicators[group][indicator]['years'] = {} if indicators[group][indicator]['years'].nil?
        indicators[group][indicator]['years'][year] = {}
        indicators[group][indicator]['years'][year]['amount_plan'] = row['amount_plan']
        indicators[group][indicator]['years'][year]['amount_fact'] = row['amount_fact']
        indicators[group][indicator]['years'][year]['description'] = row['description']
      }
    }
    indicators
  end

end
