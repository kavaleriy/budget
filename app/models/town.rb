class Town

  REGION_LEVEL = 1
  AREA_LEVEL = 2
  TOWN_LEVEL = 3
  CITY_LEVEL = 13
  VILLAGE_LEVEL = 31

  TEST_TOWN_KOATUU = '9876543210'

  include Mongoid::Document
  require 'carrierwave/mongoid'

  default_scope lambda { order_by(:title => :asc) }
  scope :get_test_town, -> {where(koatuu: TEST_TOWN_KOATUU )}
  scope :get_town_by_koatuu, -> (koatuu){where(koatuu: koatuu)}
  scope :get_town_by_title, -> (town_title) {where(title: town_title)}
  scope :get_town_by_area_title, -> (area_title) {where(area_title: area_title)}
  scope :get_town_by_part_title, -> (part) {where(title: Regexp.new("^#{part}.*"))}
  scope :get_towns_by_titles, -> (titles) {where(:title.in => titles)}

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
  has_many :taxonomy, class_name: 'Taxonomy', dependent: :nullify
  has_many :programs, class_name: 'Programs::TargetedProgram', dependent: :nullify
  has_many :users, dependent: :nullify

  validates :title, :koatuu, presence: true

  validates :koatuu,uniqueness: true,
            presence: true,
            length: {is: 10, message: I18n.t('invalid_length', length: 10) },
            numericality: { only_integer: true }

  def get_beautiful_description
    # this function get town description
    # from wikipedia.org
    # use lib/wiki_parser
    # ===================
    ## return description
    ## if data exist in wikipedia.org
    ## return data from WikiParser
    ## or
    ## return field 'description' from class Town
    # ===================
    # Work ONLY if Town belongs to area or town
    # TODO: check Town belongs to village
    WikiParser.get_wiki_town_info(self.title) || self.description || I18n.t('no_town_description_info')
  end

  def self.get_central_authority_towns(query)
    # first of all get users with authority roles mask
    city_authority_users = User.where(:roles_mask.in => [User.mask_for(:city_authority),
                                                         User.mask_for(:central_authority)]).pluck(:town_model_id)

    # second we find all they towns and last add regular expression to all they towns
    Town.where(:_id.in => city_authority_users).and(title: Regexp.new("^#{query}.*"))
  end

  def is_test?
    # this function check if town is test
    # test town should have TEST_TOWN_KOATUU
    self.koatuu.eql?(TEST_TOWN_KOATUU)
  end

  def self.town_exists?(title)
    # this function check if exist town by title
    # return true if exists else return false
    town = Town.get_town_by_title(title).first
    !town.nil?
  end

  def self.get_area_title(koatuu)
    # this function return region title
    # get one parameters koatuu
    # find town with level REGION_LEVEL and first two koatuu symbol
    # if town exist get his title
    # by default return empty string
    area_title = ''
    town = Town.areas(koatuu[0...2]).first
    area_title = town.title unless town.nil?
    area_title
  end

  def self.create_parent_area(title,koatuu)
    # this function create new town with level = AREA_LEVEL
    # get two params title is he title, koatuu is child koatuu
    # koatuu area is first 5 number params koatuu
    # skip validation because sometime town with AREA_LEVEL can have same koatuu like child town with TOWN_LEVEL
    town = Town.new
    town.title = title
    town.koatuu = "#{koatuu[0...5]}00000"
    area_title = Town.get_area_title(koatuu)
    town.level = AREA_LEVEL
    town.area_title = area_title
    town.save(validate: false)

  end

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

  def self.has_parents(level,koatuu)
    # this function return parent town or area
    # get two params level is child level,koatuu is child koatuu
    # if level = TOWN_LEVEL then we should search in regions level
    # if level = VILLAGE_LEVEL then we should search in towns level

    parent = Town
    case level.to_i
      when TOWN_LEVEL then parent = Town.regions(koatuu.slice(0,5)).first
      when VILLAGE_LEVEL then parent = Town.where(:level => TOWN_LEVEL).where(:koatuu => Regexp.new("^#{koatuu}.*")).first
    end
    parent
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
    user.town_model
    # this function return town from user if user not nil
    # function get one parameters user model
    # init user_town as new Town
    # if user have town, find this town
    # if user town name have area_title
    # add area_title to search
    # and assigned to user_town
    # return user_town(town model)
    # unless user.nil?
    #   unless user.town.empty?
    #     user_town = Town.new
    #     town_arr = user.town.split(',') unless user.nil?
    #
    #     town_title = town_arr.first
    #     town_title.strip!
    #
    #     unless town_title.empty?
    #       user_town = Town.get_town_by_title(town_title)
    #
    #       if town_arr.size > 1
    #         town_area_title = town_arr.last
    #         town_area_title.strip!
    #         user_town = user_town.get_town_by_area_title(town_area_title)
    #       end
    #     end
    #     user_town.first
    #   end
    # end
  end

  private
  def self.by_title(town_name)

    town = self.get_town_by_title(town_name).first || Town.where(_id: town_name).first
    if town.nil?
      # if town name is like "Лебедин, Сумська обл"
      town_name_arr = town_name.split(',')

      if town_name_arr.size > 1
        # cut empty space before and after string
        town_title = town_name_arr[0].strip
        town_area_title = town_name_arr[1].strip

        # split area title for check if correct area name
        town_area_title_arr = town_area_title.split(' ')
        unless town_area_title_arr[1].eql?('область')
          area = 'область'
          town_area_title = "#{town_area_title_arr[0]} #{area}"
        end
        town = self.get_town_by_title(town_title).get_town_by_area_title(town_area_title).first
      else
        # check if town name like "Івано-франківськ"
        town_name_arr_with_minus = town_name.split('-')
        if town_name_arr_with_minus.size > 1
          # convert and capitalize second town name
          town_name_arr_with_minus[1] = town_name_arr_with_minus[1].mb_chars.capitalize.to_s
          inside_town_name = town_name_arr_with_minus.join('-')
          town = self.get_town_by_title(inside_town_name).first
        end

      end
    end
    town
  end

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
