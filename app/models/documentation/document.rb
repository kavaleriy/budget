require 'file_size_validator'
require 'carrierwave/mongoid'

class Documentation::Document
  include Documentation
  include Mongoid::Document

  before_save :generate_title

  scope :get_documents_by_town,-> (town) {where(town: town)}
  scope :get_by_part_of_title, -> (q) { where(:title => Regexp.new(".*#{q}.*")) }
  scope :unlocked, -> {where({ :locked.in => [false, nil] } )}
  belongs_to :branch, class_name: 'Documentation::Branch'
  belongs_to :town
  belongs_to :owner, class_name: 'User'
  belongs_to :category, class_name: 'Documentation::Category', autosave: true

  field :title, type: String
  field :description, type: String
  field :yearFrom, type: Integer
  field :yearTo, type: Integer
  field :locked, type: Boolean, default: false

  mount_uploader :doc_file, DocumentationUploader
  skip_callback :update, :before, :store_previous_model_for_doc_file

  validates_presence_of :doc_file, message: :select_file
  validates :doc_file,
            :presence => true,
            :file_size => {
                :maximum => 11.megabytes.to_i
            }

  def select_file_message
    I18n.t('documentation.documents.model_messages.select_file')
  end

  def get_years
    years = []
    years << [self.yearFrom] unless self.yearFrom.blank?
    years << self.yearTo unless self.yearFrom == self.yearTo or self.yearTo.blank?
    years.join(' - ')
  end

  def self.get_grouped_documents_for_town(town)
    # get documents by town and not locked
    documents = self.get_documents_by_town(town).unlocked.order("yearFrom DESC")
    doc_size = documents.size
    res_hash = {}
    # group documents by year
    documents = documents.group_by(&:yearFrom)

    documents.each do |year,documents_by_year|

      year_documents = documents_by_year.group_by(&:branch_id)

      # transform keys for readeble title
      unless year_documents.empty?
        res_hash.store(year,year_documents.transform_keys{|key|
          unless key.nil?
            Documentation::Branch.find(key).title
          else
            'Інші документи'
          end
        })
      end

    end
    res_hash.store(:docs_count, doc_size)
    res_hash
  end

  private

  def generate_title
    self.title = self.doc_file.filename unless self.title?
  end

end
