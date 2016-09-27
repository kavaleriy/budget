require 'file_size_validator'

class Library::Book
  include Mongoid::Document
  require 'carrierwave/mongoid'

  scope :get_books_by_locale, -> (locale){ where(locale: locale) }

  include Mongoid::Timestamps
  field :locale, type: String, default: 'uk'
  field :category, type: String
  field :title, type: String
  field :author, type: String
  field :year_publication, type: Integer
  field :description, type: String
  field :book_url, type: String

  belongs_to :owner, class_name: 'User'

  validates :title, presence: true
  validates :book_url, presence: true, if: "book_file.blank?"

  file_size = 50
  cover_size = 1
  validates :book_file,
            presence: true, if: "book_url.blank?",
            file_size: {
              maximum: file_size.megabytes.to_i,
              message: I18n.t('mongoid.errors.messages.error_max_file_size', file_size: file_size)
            }
  validates :book_img,
            file_size: {
              maximum: cover_size.megabytes.to_i,
              message: I18n.t('mongoid.errors.messages.error_max_cover_size', cover_size: cover_size)
            }

  private
    mount_uploader :book_img, ImgBookUploader
    skip_callback :update, :before, :store_previous_model_for_book_img

    mount_uploader :book_file, BookUploader
    skip_callback :update, :before, :store_previous_model_for_book_file

    def check_valid_image_size
      if self.valid?
        unless :book_file.blank?
          self.remove_book_file
        end
      end
    end

end
