class Programs::Attachment
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String

  belongs_to :programs_target_program, :class_name => 'Programs::TargetProgram', autosave: true

  mount_uploader :attachment, ProgramsAttachmentUploader
  skip_callback :update, :before, :store_previous_model_for_attachment

  validates_presence_of :attachment, message: I18n.t('form.choose_file')

end
