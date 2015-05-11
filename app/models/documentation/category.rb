class Documentation::Category
  include Mongoid::Document
  
  belongs_to :documentation_category, autosave: true

  belongs_to :cate
  field :title, type: String
  field :preview_ico, type: String

  has_many :documentation_documents, :class_name => 'Documentation::Document', autosave: true, :dependent => :nullify
end
