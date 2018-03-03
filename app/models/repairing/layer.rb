class Repairing::Layer
  include Mongoid::Document
  include ColumnsList

  scope :by_locale, lambda { where(locale: I18n.locale) }
  scope :by_category, lambda { |category| where(repairing_category: category) }
  scope :by_status, lambda { |status| where(status: status) }
  scope :by_year, lambda { |year| where(year: year) }
  # Get taxonomies by towns
  scope :by_towns, lambda { |towns| where(:town.in => towns.split(",")) }
  # Get budget files by string in title
  scope :find_by_string, lambda { |text| where(title: /.*#{text}.*/) }

  belongs_to :town, class_name: 'Town', touch: true
  belongs_to :owner, class_name: 'User'
  belongs_to :repairing_category, class_name: 'Repairing::Category'

  field :title, type: String
  field :description, type: String
  field :locale, type: String, default: 'uk'
  field :status, type: String, default: :plan
  field :year, type: String

  mount_uploader :repairs_file, RepairingRepairUploader
  skip_callback :update, :before, :store_previous_model_for_repairs_file

  has_many :repairs, class_name: 'Repairing::Repair', autosave: true, dependent: :destroy

  validates :town, :owner, :repairing_category, :title, :status, presence: true

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
    self.repairs.each { |repair|
      geo_json << Repairing::GeojsonBuilder.build_repair(repair)
    }

    geo_json.compact

  end

  def self.valid_layers_with_repairs
    # TODO cache each layer if document would be larger than 16 mb
    # this function return BSON::Document
    # example
    # layer hash as key

    # [{"_id"=>BSON::ObjectId('56fe442467cb7d0724000003'), "repairing_category_id"=>BSON::ObjectId('560ce9576b61730991140000'), "town_id"=>BSON::ObjectId('55a818d06b617309df652500')},

    # array of repairs as value

    #  [{"_id"=>BSON::ObjectId('56fe442467cb7d0724000004'), "repair_date"=>2015-01-01 00:00:00 UTC, "coordinates"=>[49.8571335, 24.0187616], "layer_id"=>BSON::ObjectId('56fe442467cb7d0724000003')},
    #     {"_id"=>BSON::ObjectId('56fe442567cb7d0724000005'),
    #      "repair_date"=>2015-01-01 00:00:00 UTC,
    # "coordinates"=>[["49.84698", "24.01545"], ["49.84701", "24.0157"], ["49.84757", "24.01549"], ["49.84762", "24.01548"]],
    #     "layer_id"=>BSON::ObjectId('56fe442467cb7d0724000003')}

    # find all layers where is set town and get repair category and town
    layers = Repairing::Layer.collection.aggregate([
                                                       {
                                                           '$match' => {
                                                               'town_id' => {'$ne' => nil},
                                                               'locale' => I18n.locale
                                                           }
                                                       },
                                                       {
                                                           '$project' => {
                                                               'repairing_category_id' => 1,
                                                               'town_id' => 1,
                                                               'status' => 1,
                                                               'year' => 1,
                                                           }
                                                       }
                                                   ])
    # get layers ids
    layers_ids = layers.map{ |layer| layer['_id'] }

    layers_with_repairs = Repairing::Repair.collection.aggregate([
                                                                     {
                                                                         # filter documents
                                                                         '$match' =>{
                                                                             '$and' =>
                                                                                 [
                                                                                     {
                                                                                         # check if repair have layer
                                                                                         layer_id: {'$in' => layers_ids },
                                                                                         # check repair coordinates
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
                                                                             'repairing_category_id' => 1,
                                                                             'repair_start_date' => 1,
                                                                         }
                                                                     }
                                                                 # group repairs by layer
                                                                 ]).group_by{ |rep| rep['layer_id'] }
    # transform repairs key to layer hash and remove layer hash from layers array
    layers_with_repairs.transform_keys!{ |key| (layers.dup - layers.delete_if{ |layer| layer['_id'] == key}).first }
  end

end
