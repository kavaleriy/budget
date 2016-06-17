class Repairing::Map
  include Mongoid::Document

  field :title, type: String
  field :description, type: String

  has_many :layers, :class_name => 'Repairing::Layer', autosave: true, :dependent => :destroy

  def to_geo_json
    geo_json = []
    self.layers.each { |layer| geo_json << layer.to_geo_json }
    geo_json
  end
end
