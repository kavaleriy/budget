class Repairing::Layer
  include Mongoid::Document

  belongs_to :town, :dependent => :nullify
  belongs_to :owner, class_name: 'User', :dependent => :nullify

  field :title, type: String
  field :description, type: String

  mount_uploader :repairs_file, RepairingRepairUploader
  skip_callback :update, :before, :store_previous_model_for_repairs_file

  has_many :repairs, :class_name => 'Repairing::Repair', autosave: true, :dependent => :destroy

  def self.columns
    self.fields.collect{|c| c[1]}
  end

  def to_geo_json
    geoJson = []
    self.repairs.each { |repair| geoJson << Repairing::GeojsonBuilder.build_repair(repair)}
    geoJson
  end
end
