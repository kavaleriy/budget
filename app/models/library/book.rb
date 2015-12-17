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

  belongs_to :owner, class_name: 'User'


  # validates_presence_of :book_file, message: 'Потрібно вибрати Файл'
  # validates :book_url, :presence => true if validates :book_file, :presence => false,
  validates :description, :presence => true
  validates :book_url, :presence => true, if: "book_file.blank?"
  validates :book_file,
            :presence => true, if: "book_url.blank?",
            :file_size => {
                :maximum => 11.megabytes.to_i, message: 'Максимально-можливий розмір файлу - 11 мб.'
            }
  #
  # before_save :generate_title
  #
  # private
  #
  # def generate_title
  #   self.title = self.book_file_identifier unless self.title?
  # end

  private
    mount_uploader :book_file, BookUploader
    skip_callback :update, :before, :store_previous_model_for_book_file

    # after_commit :remove_previously_stored_avatar, on: :update
    skip_callback :update, :after, :remove_previously_stored_book_file
end
