class Town
  include Mongoid::Document

  default_scope lambda { order_by(:title => :asc) }

  field :koatuu, type: String
  field :title, type: String
  field :area_title, type: String
  field :note, type: String
  field :level, type: Integer
  field :community, type: Boolean
  field :community_agree, type: Boolean
  field :description, type: String
  def get_level
    return :area if self.level == 1
    return :city if self.level == 13
    return :town if [3, 31].include? self.level
  end

  field :links, type: String

  field :coordinates, type: Array
  field :geometry_type, type: String

  require 'carrierwave/mongoid'
  mount_uploader :img, TownUploader
  skip_callback :update, :before, :store_previous_model_for_img

  has_many :documentation_documents, class_name: 'Documentation::Document'
  has_many :key_indicate_indicator_files, :class_name => 'KeyIndicate::IndicatorFile', autosave: true, :dependent => :destroy
  has_many :key_indicate_map_indicators, :class_name => 'KeyIndicateMap::Indicator', autosave: true, :dependent => :destroy
  has_one :indicate_taxonomy, :class_name => 'Indicate::Taxonomy'

  after_update :clear_cache
  def clear_cache
    Rails.cache.delete(Town.name)
  end


  def to_s
    if [1, 13].index(level)
      title
    else
      "#{title}, #{area_title}"
    end
  end

  def self.to_tree
    Rails.cache.fetch( Town.name, :expires_in => Rails.env.development? ? 15.minutes : 24.hours) do
      tree = []
      self.areas.each do |area|
        area_code = area.koatuu.slice(0, 2)
        row_area = get_node(area)

        row_area[:city] = get_node(self.cities(area_code).first)
        row_area[:indicator_files] = []
        self.towns(area_code).each do |city|
          city_code = city.koatuu
          row_area[:indicator_files] << get_node(city)
        end

        tree << row_area
      end
      tree
    end
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

  # key indicators for key_indicate_map
  def get_key_indicators
    indicators = {}
    self.key_indicate_map_indicators.each{|indicator|
      next if indicator.key_indicate_map_indicator_key.nil?
      year = indicator.key_indicate_map_indicator_file['year'].to_s
      id = indicator.key_indicate_map_indicator_key._id.to_s
      indicators[year] = {} if indicators[year].nil?
      transform = indicator.key_indicate_map_indicator_key['integer_or_float']
      if transform == 'integer'
        indicators[year][id] = indicator['value'].to_i
      elsif transform == 'float'
        indicators[year][id] = indicator['value'].to_f.round(2)
      end
    }
    indicators
  end

  private

  def self.get_node(node)
    { id: "#{node.id}", title: node.title, img_url: node.img.icon.url } unless node.nil?
  end


end
