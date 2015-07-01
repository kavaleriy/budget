class TaxonomyAttachment
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String
  field :description, type: String

  belongs_to :taxonomy, :class_name => 'Taxonomy', autosave: true

  mount_uploader :attachment, TaxonomyAttachmentUploader
  skip_callback :update, :before, :store_previous_model_for_attachment

  validates_presence_of :attachment, message: I18n.t('form.choose_file')

end
