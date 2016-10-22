class Programs::IndicatorFile
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String

  belongs_to :programs_town, :class_name => 'Programs::Town', autosave: true
  has_many :programs_indicators, :class_name => 'Programs::Indicators', autosave: true, :dependent => :destroy

  mount_uploader :indicator_file, ProgramsIndicatorFileUploader
  skip_callback :update, :before, :store_previous_model_for_indicator_file

  validates_presence_of :indicator_file, message: I18n.t('form.choose_file')

  def import table, town

    groups = self.load_from_csv 'db/program_indicator_group_codes.uk.csv'    # group of indicators

    table[:rows].each{|row|
      indicator = Programs::Indicators.new
      year = row['year'].to_i
      kpkv = row['kpkv'].to_s.rjust(7, '0')
      group = groups[row['group'].to_i.to_s][:description]
      indicator.year = year
      indicator.programs_target_program = town.programs_target_programs.where(:kpkv => kpkv, :term_end.gte => year, :term_start.lte => year).first
      indicator.programs_indicator_file = self
      indicator.group = group
      indicator.indicator = row['indicator']
      indicator.amount_plan = row['amount_plan'].to_i if row['amount_plan']
      indicator.amount_fact = row['amount_fact'].to_i if row['amount_fact']
      indicator.unit = row['unit']
      indicator.description = row['description']
      indicator.save
    }

  end

  protected

  def load_from_csv file_name
    items = {}
    CSV.foreach(file_name, {:headers => true, :col_sep => ";", :quote_char => '|'}) do |row|
      items[row[0]] = { title: row[I18n.t('mongoid.taxonomy.short_title')], color: row[I18n.t('mongoid.taxonomy.color')], icon: row[I18n.t('mongoid.taxonomy.icon')], description: row[I18n.t('mongoid.taxonomy.description')] }
    end
    items
  end

end
