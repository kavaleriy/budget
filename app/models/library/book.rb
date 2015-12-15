require 'file_size_validator'

class Library::Book
  include Mongoid::Document
  require 'carrierwave/mongoid'

  include Mongoid::Timestamps
  field :title, type: String
  field :author, type: String
  field :year_publication, type: String
  field :description, type: String
  field :book_url, type: String



  # validates_presence_of :doc_file, message: 'Потрібно вибрати Файл'
  # validates :book_url, :presence => true if validates :doc_file, :presence => false,

  validates :doc_file,
            :presence => true,
            :file_size => {
                :maximum => 11.megabytes.to_i, message: 'Максимально-можливий розмір файлу - 11 мб.'
            }
  #
  # before_save :generate_title
  #
  # private
  #
  # def generate_title
  #   self.title = self.doc_file_identifier unless self.title?
  # end

  private
    mount_uploader :doc_file, BookUploader
    skip_callback :update, :before, :store_previous_model_for_doc_file

end
