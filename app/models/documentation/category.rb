class Documentation::Category
  include Mongoid::Document

  default_scope lambda { order_by(:position => :asc) }
  scope :tree_root, lambda { where( :category_id.in =>[ nil, '#']) }
  scope :tree, lambda { |category_id| where( :category_id => category_id) }

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
