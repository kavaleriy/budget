class Documentation::Category
  include Mongoid::Document
  
  has_one :parent, class_name: 'Documentation::Category', :dependent => :nullify
  belongs_to :category, class_name: 'Documentation::Category'

  field :title, type: String
  field :description, type: String
  field :preview_ico, type: String
  field :position, type: Integer

  has_many :documentation_documents, :class_name => 'Documentation::Document', autosave: true, :dependent => :nullify

  def self.tree_root
    Documentation::Category.where( :category_id.in =>[ nil, '#'])
  end
  def childrens
    Documentation::Category.where(category_id: id).all
  end

end
