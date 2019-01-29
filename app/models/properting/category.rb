class Properting::Category
  include Mongoid::Document

  default_scope -> { order_by(position: :asc) }
  scope :by_locale, -> { where(locale: I18n.locale) }
  scope :tree_root, -> { where(:category_id.in => [nil, '#']) }
  scope :tree, ->(category_id) { where(category_id: category_id) }

  has_many :properting_layers, class_name: 'Properting::Layer', autosave: true, dependent: :nullify
  has_many :properting_properties, class_name: 'Properting::Property', autosave: true, dependent: :nullify
  # has_one :parent, class_name: 'Properting::Category', dependent: :nullify
  has_many :categories, class_name: 'Properting::Category', autosave: true, dependent: :destroy
  belongs_to :category, class_name: 'Properting::Category'

  field :title, type: String
  field :icon, type: String
  field :color, type: String
  field :position, type: Integer
  field :locale, type: String, default: 'uk'

  require 'carrierwave/mongoid'
  mount_uploader :img, Properting::CategoryImgUploader
  skip_callback :update, :before, :store_previous_model_for_img

  def self.tree_root
    Properting::Category.where(:category_id.in => [nil, '#']).by_locale
  end

  def self.with_image
    Properting::Category.where(:img.ne => nil).by_locale
  end

  def childrens
    Properting::Category.where(category_id: id).by_locale
  end

  def self.get_category_icons
    # this function return json array root categories
    # where key is category.id and value is category.img

    root_categories = with_image.to_a
    res = {}
    root_categories.each do |category|
      img = ''
      img = category.img.thumb.url || category.img unless category.img.nil?
      res.store(category.id, img)
    end
    res.to_json
  end
end
