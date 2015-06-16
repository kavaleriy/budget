class Programs::ExpencesFile
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String
  field :description, type: String

  belongs_to :programs_target_program, :class_name => 'Programs::TargetProgram', autosave: true

  mount_uploader :expences_file, ExpencesFileUploader
  skip_callback :update, :before, :store_previous_model_for_expences_file

  validates_presence_of :expences_file, message: I18n.t('form.choose_file')

end
