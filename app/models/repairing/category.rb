class Repairing::Category
  include Mongoid::Document

  default_scope lambda { order_by(:position => :asc) }
  scope :tree_root, lambda { where( :category_id.in =>[ nil, '#']) }
  scope :tree, lambda { |category_id| where( :category_id => category_id) }

  has_many :repairing_layers, :class_name => 'Repairing::Layer', autosave: true, :dependent => :nullify
  has_one :parent, class_name: 'Repairing::Category', :dependent => :nullify
  belongs_to :category, class_name: 'Repairing::Category'

  field :title, type: String
  field :icon, type: String
  field :color, type: String
  field :position, type: Integer

  def self.tree_root
    Repairing::Category.where( :category_id.in =>[ nil, '#'])
  end

  def childrens
    Repairing::Category.where(category_id: id).all
  end
end
