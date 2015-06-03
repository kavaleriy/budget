class EventAttachment
  include Mongoid::Document

  embedded_in :event
  # belongs_to  :event

  field :name, type: String
  field :description, type: String

  require 'carrierwave/mongoid'


  belongs_to :event, class_name: 'Event', autosave: true



  mount_uploader :doc_file, EventAttachmentsUploader
  skip_callback :update, :before, :store_previous_model_for_doc_file

  validates_presence_of :doc_file, message: 'Потрібно вибрати Файл'

  # before_save :generate_title
  #
  # private
  #
  # def generate_title
  #   self.name = self.doc_file_identifier unless self.title?
  # end

end
