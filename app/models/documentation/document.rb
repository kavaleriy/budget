require 'file_size_validator'

class Documentation::Document
  include Mongoid::Document

  require 'carrierwave/mongoid'


  belongs_to :category, class_name: 'Documentation::Category', autosave: true

  field :title, type: String
  field :description, type: String

  field :yearFrom, type: Integer
  field :yearTo, type: Integer
  belongs_to :branch, class_name: 'Documentation::Branch'
  belongs_to :town
  belongs_to :owner, class_name: 'User'

  mount_uploader :doc_file, DocumentationUploader
  skip_callback :update, :before, :store_previous_model_for_doc_file

  validates_presence_of :doc_file, message: 'Потрібно вибрати Файл'
  validates :doc_file,
            :presence => true,
            :file_size => {
                :maximum => 11.megabytes.to_i
            }

  before_save :generate_title

  private

  def generate_title
    self.title = self.doc_file_identifier unless self.title?
  end

  private

end
