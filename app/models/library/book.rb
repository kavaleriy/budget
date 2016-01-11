require 'file_size_validator'

class Library::Book
  include Mongoid::Document
  require 'carrierwave/mongoid'

  include Mongoid::Timestamps
  field :category, type: String
  field :title, type: String
  field :author, type: String
  field :year_publication, type: Integer
  field :description, type: String
  field :book_url, type: String

  # attr_accessor :category
  belongs_to :owner, class_name: 'User'

  validates :title, :presence => true
  validates :book_url, :presence => true, if: "book_file.blank?"
  validates :book_file,
            :presence => true, if: "book_url.blank?",
            :file_size => {
                :maximum => 50.megabytes.to_i, message: 'Максимально-можливий розмір файлу - 50 мб.'
            }

  scope :category, -> { select(where(author: true)).distinct }


  scope :active, -> { where category: "" }
  scope :inactive, -> { where category: nil }

  def self.category
    self.categories
  end
  private
    mount_uploader :book_img, ImgBookUploader
    skip_callback :update, :before, :store_previous_model_for_book_img

    mount_uploader :book_file, BookUploader
    skip_callback :update, :before, :store_previous_model_for_book_file

    def self.categories
      # @categories = Library::Book.select('author')  #.distinct
      self.distinct.pluck(:author)
    end

    # def self.categories
    #   @categories = Library::Book.all(:select => "DISTINCT author")  #.distinct
    # end


end
