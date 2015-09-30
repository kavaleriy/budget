class Repairing::Layer
  include Mongoid::Document
  # bootstrap form
  include ColumnsList

  belongs_to :town, :dependent => :nullify
  belongs_to :owner, class_name: 'User', :dependent => :nullify
  belongs_to :repairing_category, :class_name => 'Repairing::Category', :dependent => :nullify

  field :title, type: String
  field :description, type: String

  mount_uploader :repairs_file, RepairingRepairUploader
  skip_callback :update, :before, :store_previous_model_for_repairs_file

  has_many :repairs, :class_name => 'Repairing::Repair', autosave: true, :dependent => :destroy


  def to_geo_json
    geoJson = []
    self.repairs.each { |repair|
      geoJson << Repairing::GeojsonBuilder.build_repair(repair)
    }

    geoJson.compact

  end
end
