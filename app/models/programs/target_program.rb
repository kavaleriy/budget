class Programs::TargetProgram
  include Mongoid::Document

  field :kpkv, type: String      # program code
  field :kfkv, type: String      # functional code (branch)
  field :title, type: String
  field :author, type: String
  field :targets, type: String
  field :tasks, type: Array
  field :expected_results, type: Array
  field :participants, type: Array
  field :term_start, type: String
  field :term_end, type: String
  field :description, type: String

  belongs_to :programs_town, :class_name => 'Programs::Town', autosave: true
  has_many :programs_expences_files, :class_name => 'Programs::ExpencesFile', autosave: true, :dependent => :destroy
  has_many :programs_indicator_files, :class_name => 'Programs::IndicatorFile', autosave: true, :dependent => :destroy

  validates :title, presence: true
  validates :kpkv, :uniqueness => {:scope => :programs_town}

  def import row
    self.kpkv = row['kpkv']
    self.kfkv = row['kfkv']
    self.title = row['title']
    self.targets = row['targets']
    self.tasks = row['tasks'].split('//')
    self.expected_results = row['expected_results'].split('//')
    self.participants = row['participants'].split('//')
    self.term_start = row['term_start'].to_i
    self.term_end = row['term_end'].to_i
    self.description = row['description']
  end

  def get_total_amount
    amounts = {}
    self.programs_expences_files.each{|file|
      if file.expences['total']
        amounts['amount_plan'] = file.expences['total']['amount_plan'] if file.expences['total']['amount_plan']
        amounts['amount_fact'] = file.expences['total']['amount_fact'] if file.expences['total']['amount_fact']
      end
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
        indicators[group][indicator][year] = {}
        indicators[group][indicator][year]['amount_plan'] = row['amount_plan']
        indicators[group][indicator][year]['amount_fact'] = row['amount_fact']
        indicators[group][indicator][year]['unit'] = row['unit']
        indicators[group][indicator][year]['description'] = row['description']
      }
    }
    indicators
  end

  def get_phases
    phases = {}
    self.programs_expences_files.each{|file|
      if file.expences['phases']
        file.expences['phases'].each{|phase, value|
          phases[phase] = value
        }
      end
    }
    phases
  end

end
