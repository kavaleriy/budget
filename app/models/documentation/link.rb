class Documentation::Link
  include Mongoid::Document

  belongs_to :link_category, class_name: 'Documentation::LinkCategory', autosave: true

  field :title, type: String
  field :value, type: String


end