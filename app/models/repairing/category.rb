class Repairing::Category
  include Mongoid::Document

  default_scope lambda { order_by(:position => :asc) }
  scope :by_locale, lambda { where( locale: I18n.locale ) }
  scope :tree_root, lambda { where( :category_id.in =>[ nil, '#']) }
  scope :tree, lambda { |category_id| where( :category_id => category_id) }

  has_many :repairing_layers, :class_name => 'Repairing::Layer', autosave: true, :dependent => :nullify
  has_many :repairing_repairs, :class_name => 'Repairing::Repair', autosave: true, :dependent => :nullify
  has_one :parent, class_name: 'Repairing::Category', :dependent => :nullify
  belongs_to :category, class_name: 'Repairing::Category'

  field :title, type: String
  field :icon, type: String
  field :color, type: String
  field :position, type: Integer
  field :locale, type: String, default: 'uk'

  require 'carrierwave/mongoid'
  mount_uploader :img, Repairing::CategoryImgUploader
  skip_callback :update, :before, :store_previous_model_for_img

  def self.tree_root
    Repairing::Category.where( :category_id.in =>[ nil, '#']).by_locale
  end

  def childrens
    Repairing::Category.where(category_id: id).by_locale
  end

  def self.get_category_icons
    # this function return json array root categories
    # where key is category.id and value is category.img

    root_categories = self.tree_root.to_a
    res = {}
    root_categories.each do |category|
      img = ''
      img = category.img.thumb.url || category.img unless category.img.nil?
      res.store(category.id,img)
    end

    res.to_json
  end

end
