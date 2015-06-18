class Programs::IndicatorFile
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String
  field :description, type: String
  field :indicators, type: Hash
  field :groups, type: Hash

  belongs_to :programs_target_program, :class_name => 'Programs::TargetProgram', autosave: true

  mount_uploader :indicator_file, ProgramsIndicatorFileUploader
  skip_callback :update, :before, :store_previous_model_for_indicator_file

  validates_presence_of :indicator_file, message: I18n.t('form.choose_file')

  def import table

    groups = self.load_from_csv 'db/program_indicator_group_codes.csv'    # group of indicators

    self.indicators = {}

    table[:rows].each{|row|
      group = groups[row['group'].to_i.to_s][:title]
      indicator = row['indicator']
      year = row['year']
      indicators[group] = {} if indicators[group].blank?
      indicators[group][indicator] = {} if indicators[group][indicator].blank?
      indicators[group][indicator][year] = {} if indicators[group][indicator][year].blank?
      indicators[group][indicator][year]['amount_plan'] = row['amount_plan']
      indicators[group][indicator][year]['amount_fact'] = row['amount_fact']
      indicators[group][indicator][year]['unit'] = row['unit']
      indicators[group][indicator][year]['description'] = row['description']
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
