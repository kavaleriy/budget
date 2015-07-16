class Town
  include Mongoid::Document

  default_scope lambda { order_by(:title => :asc) }

  field :koatuu, type: String
  field :title, type: String
  field :note, type: String
  field :level, type: Integer

  field :links, type: String

  require 'carrierwave/mongoid'

  mount_uploader :img, TownUploader
  skip_callback :update, :before, :store_previous_model_for_img

  has_one :town_geo

  has_many :documentation_documents, class_name: 'Documentation::Document'

  def to_s
    self.title
  end

  def self.to_tree
    tree = []
    self.areas.each do |area|
      area_code = area.koatuu.slice(0, 2)
      row_area = get_node(area)

      row_area[:city] = get_node(self.acities(area_code).first)
      row_area[:regions] = []

      self.regions(area_code).each do |region|
        region_code = region.koatuu.slice(0, 5)
        row_regions = get_node(region)
        row_regions[:towns] = []
        self.cities(region_code).each do |city|
          city_code = city.koatuu
          row_regions[:towns] << get_node(city)
        end
        row_area[:regions] << row_regions
      end

      tree << row_area
    end
    tree
  end

  def self.get_node(node)
    { id: "#{node.id}", title: node.title, img_url: node.img.icon.url } unless node.nil?
  end


  def self.areas(koatuu = '')
    self.where(:level => 1).where(:koatuu => Regexp.new("^#{koatuu}.*"))
  end
  def self.regions(koatuu = '')
    self.where(:level => 2).where(:koatuu => Regexp.new("^#{koatuu}.*"))
  end
  def self.acities(koatuu = '')
    self.where(:level => 13).where(:koatuu => Regexp.new("^#{koatuu}.*"))
  end
  def self.cities(koatuu = '')
    self.where(:level.in => [3, 31]).where(:koatuu => Regexp.new("^#{koatuu}.*"))
  end

end
