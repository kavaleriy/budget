class Documentation::Document
  include Mongoid::Document
  
  belongs_to :documentation_category, autosave: true

  field :title, type: String
  field :description, type: String
  field :issued, type: Time
  field :path, type: String
  field :preview_ico, type: String
end
