class Repairing::Map
  include Mongoid::Document

  field :title

  has_many :locations, :class_name => 'Repairing::Map::Location', autosave: true, :dependent => :destroy
end
