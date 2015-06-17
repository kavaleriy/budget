class Programs::IndicatorFile
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String
  field :description, type: String

  belongs_to :programs_target_program, :class_name => 'Programs::TargetProgram', autosave: true

  mount_uploader :indicator_file, ProgramsIndicatorFileUploader
  skip_callback :update, :before, :store_previous_model_for_indicator_file

  validates_presence_of :indicator_file, message: I18n.t('form.choose_file')

end
