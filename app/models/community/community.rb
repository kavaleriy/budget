class Community::Community
  include Mongoid::Document

  field :title, type: String
  field :participants, type: String
  field :coordinates, type: Array
  field :geometry_type, type: String
  field :agree, type: Boolean
  field :color, type: String
  field :icon, type: String

  belongs_to :town, :class_name => '::Town', autosave: true

end
