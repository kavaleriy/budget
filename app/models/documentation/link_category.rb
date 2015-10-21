class Documentation::LinkCategory
  include Mongoid::Document

  default_scope lambda { order_by(:position => :asc) }
  scope :tree_root, lambda { where( :link_category_id.in =>[ nil, '#']) }
  scope :tree, lambda { |link_category_id| where( :link_category_id => link_category_id) }

  has_one :parent, class_name: 'Documentation::LinkCategory', :dependent => :nullify
  belongs_to :link_category, class_name: 'Documentation::LinkCategory'

  field :title, type: String
  field :description, type: String
  field :preview_ico, type: String
  field :position, type: Integer
  # field :link_category_id, type: String
  has_many :documentation_links, :class_name => 'Documentation::Link', autosave: true, :dependent => :nullify

  def self.tree_root
    Documentation::LinkCategory.where( :link_category_id.in =>[ nil, '#'])
  end

  def childrens
    Documentation::LinkCategory.where(link_category_id: id).all
  end

end
