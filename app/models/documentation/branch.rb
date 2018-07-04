class Documentation::Branch
  include Mongoid::Document
  field :title, type: String
  field :color, type: String

  # bootstrap form
  include ColumnsList

  has_many :document_category, class_name: 'Documentation::Document'

  validates_uniqueness_of :title
end
