class Properting::Layer
  include Mongoid::Document
  include ColumnsList

  scope :by_locale, lambda { where(locale: I18n.locale) }
  scope :by_category, lambda { |category| where(properting_category: category) }
  scope :by_status, lambda { |status| where(status: status) }
  scope :by_year, lambda { |year| where(year: year) }
  # Get taxonomies by towns
  scope :by_towns, lambda { |towns| where(:town.in => towns.split(",")) }
  # Get budget files by string in title
  scope :find_by_string, lambda { |text| where(title: /.*#{text}.*/) }
  scope :get_by_ids, ->(ids) { where(:id.in => ids) }

  belongs_to :town, class_name: 'Town', touch: true
  belongs_to :owner, class_name: 'User'
  belongs_to :properting_category, class_name: 'Properting::Category'

  field :title, type: String
  field :description, type: String
  field :locale, type: String, default: 'uk'
  field :status, type: String, default: :plan
  field :year, type: String

  mount_uploader :properties_file, PropertyPhotoUploader
  skip_callback :update, :before, :store_previous_model_for_properties_file

  has_many :properties, class_name: 'Properting::Property', autosave: true, dependent: :destroy

  validates :town, :owner, :properting_category, :title, :status, presence: true

  def self.visible_to user
    files = if user.nil?
      self.where(owner: nil)
    elsif user.has_role? :admin
      self.all
    else
      self.where(owner: user.id)
    end
    files || []
  end

  def to_geo_json
    geo_json = []
    self.properties.each { |property|
      geo_json << Properting::GeojsonBuilder.build_property(property)
    }
    geo_json.compact
  end

  def self.valid_layers_with_properties
    # TODO cache each layer if document would be larger than 16 mb
    layers = Properting::Layer.collection.aggregate([
                                                       {
                                                           '$match' => {
                                                               'town_id' => {'$ne' => nil},
                                                               'locale' => I18n.locale
                                                           }
                                                       },
                                                       {
                                                           '$project' => {
                                                               'properting_category_id' => 1,
                                                               'town_id' => 1,
                                                               'status' => 1,
                                                               'year' => 1,
                                                           }
                                                       }
                                                   ])
    # get layers ids
    layers_ids = layers.map{ |layer| layer['_id'] }

    layers_with_properties = Properting::Property.collection.aggregate([
                                                                     {
                                                                         # filter documents
                                                                         '$match' =>{
                                                                             '$and' =>
                                                                                 [
                                                                                     {
                                                                                         layer_id: {'$in' => layers_ids },
                                                                                         coordinates: {'$ne' => nil},
                                                                                     }
                                                                                 ]
                                                                         }
                                                                     },
                                                                     {
                                                                         # show this fields
                                                                         '$project' => {
                                                                             'updated_at' => 1,
                                                                             'coordinates' => 1,
                                                                             'layer_id' => 1,
                                                                             'properting_category_id' => 1,
                                                                             'property_start_date' => 1,
                                                                         }
                                                                     }
                                                                 ]).group_by{ |rep| rep['layer_id'] }
    layers_with_properties.transform_keys!{ |key| (layers.dup - layers.delete_if{ |layer| layer['_id'] == key}).first }
  end
end
