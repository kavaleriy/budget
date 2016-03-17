class ContentManager::PageContainer
  include Mongoid::Document
  ABOUT_US = 0
  BUDGET_SYSTEM = 1
  VISUALISATION = 2
  PUBLIC_CONTROL = 3

  has_many :subordinates, class_name: "ContentManager::PageContainer",foreign_key: "p_id"
  # has_many :parent, class_name: "ContentManager::PageContainer",foreign_key: "id"

  scope :get_all_child, -> { where(:p_id.ne => nil )}
  scope :get_parent_menu, ->(category) { where(alias: category) }
  scope :get_child_link, ->(parent) { where(p_id: parent)}
  scope :get_page_by_alias, ->(as) { where(alias: as )}
  scope :get_menu_list, -> { where(p_id: nil) }

  field :uk, type: Hash
  field :en, type: Hash
  field :header, type: String
  field :content, type: String
  field :alias, type: String
  field :p_id, type: String
  field :link, type: String

  validates :alias, presence: true
  validates :alias, uniqueness: true



  def self.get_constant_to_h
    result = {}
    constants = ContentManager::PageContainer.constants(false)
    constants.each do |constant|
      result.store(constant.to_s,ContentManager::PageContainer.const_get(constant))
    end
    result

  end

  def self.get_all_menu
    result = {}
    const_arr = get_constant_to_h
    const_arr.each do |key, value|
      obj = ContentManager::PageContainer.get_page_by_alias(value).first
      arr = get_child_link(obj.id).to_a
      result.store(obj,arr)
    end
    result
  end
end
