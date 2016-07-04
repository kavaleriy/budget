class ContentManager::PageContainer
  include Mongoid::Document
  ABOUT_US = 0
  # BUDGET_SYSTEM = 1
  VISUALISATION = 2
  PUBLIC_CONTROL = 3

  COMMUNITY_INFO_ALIAS = 'community'
  OFFICIAL_INFO_ALIAS = 'official'

  has_many :subordinates, class_name: "ContentManager::PageContainer",foreign_key: "p_id"
  # has_many :parent, class_name: "ContentManager::PageContainer",foreign_key: "id"

  scope :get_all_child, -> { where(:p_id.ne => nil )}
  scope :get_parent_menu, ->(category) { where(alias: category) }
  scope :get_child_link, ->(parent) { where(p_id: parent)}
  scope :get_page_by_alias, ->(as) { where(alias: as )}
  scope :get_menu_list, -> { where(:alias.in => get_constants_in_a )}

  field :locale_data, type: Hash
  field :alias, type: String
  field :p_id, type: String
  field :link, type: String

  validates :alias, presence: true
  validates :alias, uniqueness: true
  validate :locale_data_has_not_empty

  def self.get_constants_in_a
    res = []
    consts = get_constants_name
    consts.each { |const| res << get_const_value_by_name(const) }
    res
  end

  def self.get_constant_to_h
    result = {}
    constants = get_constants_name
    constants.each do |constant|
      result.store(constant.to_s,get_const_value_by_name(constant))
    end
    result

  end

  def self.get_constants_name
    ContentManager::PageContainer.constants(false)
  end

  def self.get_const_value_by_name (name)
    ContentManager::PageContainer.const_get(name)
  end

  def self.get_all_menu
    result = {}
    const_arr = get_constant_to_h
    const_arr.each do |key, value|
      if value.is_a? Numeric
        obj = ContentManager::PageContainer.get_page_by_alias(value).first
        arr = get_child_link(obj.id).to_a
        result.store(obj,arr)
      end
    end
    result
  end

  def self.get_info_pages
    self.get_page_by_alias(COMMUNITY_INFO_ALIAS) + self.get_page_by_alias(OFFICIAL_INFO_ALIAS)
  end


  # validators

  def locale_data_has_not_empty
    locale = I18n.locale
    errors.add(:locale_data, "Header is empty!") if locale_data[locale][:header].empty?
    errors.add(:locale_data, "Content is empty!") if locale_data[locale][:content].empty?
  end
end
