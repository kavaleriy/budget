class Community::Community
  include Mongoid::Document

  field :coordinates, type: Array
  field :geometry_type, type: String
  field :agree, type: Boolean

  belongs_to :town, :class_name => '::Town', autosave: true

end
