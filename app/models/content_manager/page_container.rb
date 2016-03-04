class ContentManager::PageContainer
  include Mongoid::Document

  field :header, type: String
  field :content, type: String

  validates :header,:content, presence: true
end
