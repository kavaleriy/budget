class ContentManager::PageContainer
  include Mongoid::Document
  ABOUT_US = 0
  BUDGET_SYSTEM = 1
  VISUALISATION = 2
  PUBLIC_CONTROL = 3

  scope :get_parent_menu, ->(category) { where(alias: category) }

  field :header, type: String
  field :content, type: String
  field :alias, type: String
  field :p_id, type: String
  field :link, type: String

  validates :header, presence: true
  validates :alias, uniqueness: true

  def self.get_constant_to_h
    result = {}
    constants = ContentManager::PageContainer.constants(false)
    constants.each do |constant|
      result.store(constant.to_s,ContentManager::PageContainer.const_get(constant))
    end
    result

  end
end
