class Document::Category
  include Mongoid::Document
  field :title, type: String
  field :preview_ico, type: String
end
