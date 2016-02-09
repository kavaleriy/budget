class Town
  include Mongoid::Document

  default_scope lambda { order_by(:title => :asc) }

  field :koatuu, type: String
  field :title, type: String
  field :area_title, type: String
  field :note, type: String
  field :level, type: Integer
  field :description, type: String
  def get_level
    return :area if self.level == 1
    return :city if self.level == 13
    return :town if [3, 31].include? self.level
  end

  field :links, type: String

  field :coordinates, type: Array
  field :bounds, type: Array
  field :center, type: Array
  field :geometry_type, type: String

  require 'carrierwave/mongoid'
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

  def self.get_town_items_hash (town_object)
    @town = town_object
    town = nil
    town = @town.title unless @town.blank?
    result = {}
    result.store("budget" ,Town.get_hash_by_item("budget",@town)) if Taxonomy.where(:owner => town).first
    result.store("programs" ,Town.get_hash_by_item("programs",@town)) if Programs::Town.where(:name => town).first
    result.store("calendar" ,Town.get_hash_by_item("calendar",@town)) if Calendar.where(:town => town).first
    result.store("repair" ,Town.get_hash_by_item("repair",@town))
    result.store("key_docs" ,Town.get_hash_by_item("keys_docs",@town))
    if @town.blank?
      @town = Town.new(:id => 'test',
                       :title => 'Демонстрація типового профілю міста',
                       :description => 'Розділ містить короткі відомості про місто, особливості бюджету і т.п...',
                       :links => '<a href="http://www.openbudget.in.ua" target="_blank" rel="nofollow">http://www.openbudget.in.ua/</a>')
      result.store("keys" ,Town.get_hash_by_item("keys",@town))
      result.store("indicators" ,Town.get_hash_by_item("indicators",@town)) if Indicate::Taxonomy.where(:town => nil)
    else

      result.store("keys" ,Town.get_hash_by_item("keys",@town)) if @town.key_indicate_map_indicators
      result.store("indicators" ,Town.get_hash_by_item("indicators",@town)) if Indicate::Taxonomy.where(:town => @town).first
    end

    result
  end



  private

  def self.get_node(node)
    { id: "#{node.id}", title: node.title, img_url: node.img.icon.url } unless node.nil?
  end

  def self.img_url (item)
    "/assets/public/" + item + ".jpg"
  end

  def self.title_for_portfolio (item)
    I18n.t('public.towns.portfolio.' + item)
  end

  def self.get_item_hash(item_img_src,item_title,item_url)
    arr = {'title' => item_title, 'img_src' => item_img_src, 'url'=> item_url}
    arr
  end
  def self.get_hash_by_item(item,town_object)
    item_img_src = self.img_url(item)
    item_title = self.title_for_portfolio(item)
    item_url = "public_budget_files_path(town_object)"
    arr = get_item_hash(item_img_src,item_title,item_url)
    arr
  end
end
