class Documentation::Document
  include Mongoid::Document

  require 'carrierwave/mongoid'


  belongs_to :category, class_name: 'Documentation::Category', autosave: true

  field :title, type: String
  field :description, type: String

  field :yearFrom, type: Date
  field :yearTo, type: Date

  belongs_to :branch, class_name: 'Documentation::Branch', :dependent => :nullify
  belongs_to :town, :dependent => :nullify
  belongs_to :owner, class_name: 'User', :dependent => :nullify

  mount_uploader :doc_file, DocumentationUploader
  skip_callback :update, :before, :store_previous_model_for_doc_file

  validates_presence_of :doc_file, message: 'Потрібно вибрати Файл'

  before_save :generate_title

  private

  def generate_title
    self.title = self.doc_file_identifier unless self.title?
  end

  private

end
