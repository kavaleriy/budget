require 'file_size_validator'
require 'carrierwave/mongoid'

class Documentation::Document
  include Mongoid::Document

  before_save :generate_title

  skip_callback :update, :before, :store_previous_model_for_doc_file

  belongs_to :branch, class_name: 'Documentation::Branch'
  belongs_to :town
  belongs_to :owner, class_name: 'User'
  belongs_to :category, class_name: 'Documentation::Category', autosave: true

  field :title, type: String
  field :description, type: String
  field :yearFrom, type: Integer
  field :yearTo, type: Integer
  field :locked, type: Boolean

  mount_uploader :doc_file, DocumentationUploader

  validates_presence_of :doc_file, message: 'Потрібно вибрати Файл'
  validates :doc_file,
            :presence => true,
            :file_size => {
                :maximum => 11.megabytes.to_i
            }

  def check_access(user)
    # this function check access to update or destroy document
    # get one parameter user model
    # return true if user admin
    # return true if user created this document
    # else return false

    binding.pry
    user.is_admin? || self.owner.eql?(user)
  end

  def get_years
    years = []
    years << [self.yearFrom] unless self.yearFrom.blank?
    years << self.yearTo unless self.yearFrom == self.yearTo or self.yearTo.blank?
    years.join(' - ')
  end

  private

  def generate_title
    self.title = self.doc_file_identifier unless self.title?
  end

  private

end
