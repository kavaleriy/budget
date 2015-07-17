class Town
  include Mongoid::Document

  default_scope lambda { order_by(:title => :asc) }

  field :koatuu, type: String
  field :title, type: String
  field :area_title, type: String
  field :note, type: String
  field :level, type: Integer

  field :links, type: String

  field :coordinates, type: Array

  require 'carrierwave/mongoid'

  mount_uploader :img, TownUploader
  skip_callback :update, :before, :store_previous_model_for_img

  has_many :documentation_documents, class_name: 'Documentation::Document'

  def to_s
    if [1, 13].index(level)
      title
    else
      "#{title}, #{area_title}"
    end
  end

  def self.to_tree
    Rails.cache.fetch( self.name, :expires_in => Rails.env.development? ? 15.minutes : 24.hours) do
      tree = []
      self.areas.each do |area|
        area_code = area.koatuu.slice(0, 2)
        row_area = get_node(area)

        row_area[:city] = get_node(self.cities(area_code).first)
        row_area[:towns] = []
        self.towns(area_code).each do |city|
          city_code = city.koatuu
          row_area[:towns] << get_node(city)
        end

        tree << row_area
      end
      tree
    end
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
  def self.cities(koatuu = '')
    self.where(:level => 13).where(:koatuu => Regexp.new("^#{koatuu}.*"))
  end
  def self.towns(koatuu = '')
    self.where(:level.in => [3, 31]).where(:koatuu => Regexp.new("^#{koatuu}.*"))
  end

end
