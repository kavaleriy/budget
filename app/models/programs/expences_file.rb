class Programs::ExpencesFile
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String

  belongs_to :programs_town, :class_name => 'Programs::Town', autosave: true
  has_many :programs_expences, :class_name => 'Programs::Expences', autosave: true, :dependent => :destroy

  mount_uploader :expences_file, ExpencesFileUploader
  skip_callback :update, :before, :store_previous_model_for_expences_file

  validates_presence_of :expences_file, message: I18n.t('form.choose_file')

  def import table, town

    table[:rows].each{|row|
      expence = Programs::Expences.new
      year = row['year'].to_i
      kpkv = row['kpkv'].to_s.rjust(7, '0')
      expence.year = year
      expence.programs_target_program = town.programs_target_programs.where(:kpkv => kpkv, :term_end.gte => year, :term_start.lte => year).first
      check_expence = expence.programs_target_program.programs_expences.where(:year => year).first
      expence = check_expence if check_expence
      expence.programs_expences_file = self
      expence.amount_plan = row['amount_plan'].to_i if row['amount_plan']
      expence.amount_fact = row['amount_fact'].to_i if row['amount_fact']
      expence.description = row['description']
      expence.save
    }


  end

end
