class Library::Book
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  # field :year_published, type: String
  #field :link, type: String
  field :description, type: String


  mount_uploader :doc_file, DocumentationUploader
  skip_callback :update, :before, :store_previous_model_for_doc_file

  validates_presence_of :doc_file, message: 'Потрібно вибрати Файл'
  validates :doc_file,
            :presence => true,
            :file_size => {
                :maximum => 11.megabytes.to_i
            }
  #
  # before_save :generate_title
  #
  # private
  #
  # def generate_title
  #   self.title = self.doc_file_identifier unless self.title?
  # end
end
