class Town

  REGION_LEVEL = 1
  AREA_LEVEL = 2
  TOWN_LEVEL = 3
  CITY_LEVEL = 13
  VILLAGE_LEVEL = 31


  include Mongoid::Document
  require 'carrierwave/mongoid'

  default_scope lambda { order_by(:title => :asc) }
  scope :get_test_town, -> {where(title: 'Test')}
  scope :get_town_by_koatuu, -> (koatuu){where(koatuu: koatuu)}
  scope :get_town_by_title, -> (town_title) {where(title: town_title)}
  after_update :clear_cache

  field :koatuu, type: String
  field :title, type: String
  field :area_title, type: String
  field :note, type: String
  field :level, type: Integer
  field :description, type: String
  field :links, type: String
  field :coordinates, type: Array
  field :bounds, type: Array
  field :center, type: Array
  field :geometry_type, type: String

  mount_uploader :img, TownUploader
  skip_callback :update, :before, :store_previous_model_for_img

  # counters for per-capita calculations
  embeds_one :counters, class_name: 'TownCounter'
  has_many :documentation_documents, class_name: 'Documentation::Document'
  has_many :key_indicate_indicator_files, :class_name => 'KeyIndicate::IndicatorFile', autosave: true, :dependent => :destroy
  has_many :key_indicate_map_indicators, :class_name => 'KeyIndicateMap::Indicator', autosave: true, :dependent => :destroy
  has_one :indicate_taxonomy, :class_name => 'Indicate::Taxonomy'
  has_many :community_communities, :class_name => 'Community::Community', autosave: true
  has_one :export_budget

  validates :title ,presence: true

  validates :koatuu, uniqueness: true,
            presence: true,
            length: {is: 10, message: I18n.t('invalid_length', length: 10) },
            numericality: { only_integer: true }


  def self.get_levels_array
    # this function return levels array
    # first of all function get all *_LEVEL consts name
    # get value by this consts
    # then  build hash
    # where *_LEVEL const is key and value is human readable string
    const_names = Town.constants(false)

    consts = []
    const_names.each do |name|
      consts << [Town.const_get(name),I18n.t(name.to_s)]
    end
    consts
  end

  def get_level
    return :area if self.level == 1
    return :city if self.level == 13
    return :town if [3, 31].include? self.level
  end

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
    Rails.cache.fetch( Town.name, :expires_in => Rails.env.development? ? 10.seconds : 2.hours) do
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

        self.regions(area_code).each do |city|
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
    koatuu_code = koatuu
    if koatuu == '32'
      koatuu_code = '80'
    end
    self.where(:level => 13).where(:koatuu => Regexp.new("^#{koatuu_code}.*"))
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

  def save_counter_by_xls(arr)
    if self.counters.nil?
      self.counters = TownCounter.new(arr)
    else
      self.counters.update(arr)
    end
    self.counters.save!
  end

  def self.get_user_town(user)
    # this function return town from user
    # function get one parameters user model
    # init user_town as hash with empty params
    # if user have town, find this town
    # and assigned to user_town hash
    # return user_town
    user_town = {id: '',title: ''}
    town_title = ''
    town_title = user.town unless user.nil?
    unless town_title.empty?
      user_town = Town.get_town_by_title(town_title).first
    end
    user_town
  end

  private

  def self.get_node(node)
    { id: "#{node.id}", title: node.title, img_url: node.img.icon.url } unless node.nil?
  end

  def self.img_url (item)
    "/assets/public/" + item + ".jpg"
  end


  def self.edit_counters_by_table(table)
    errors_arr = []
    index = 1
    unless table.nil?
      table[:rows].each do |rows|
        koatuu = rows.delete('koatuu').to_i
        town = Town.get_town_by_koatuu(koatuu).first
        unless town.nil?
          town.save_counter_by_xls(rows)
        else
          errors_arr << I18n.t('xls.error_row_number',koatuu: koatuu,row: index)
        end
        index = index+1
      end
    end
    errors_arr
  end

end
