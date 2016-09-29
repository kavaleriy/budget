module Repairing
  class Repair
    include Mongoid::Document

    belongs_to :layer, class_name: 'Repairing::Layer'
    validates :layer, presence: true

    belongs_to :repairing_category, :class_name => 'Repairing::Category', :dependent => :nullify

    field :obj_owner, type: String
    field :subject, type: String
    field :work, type: String
    field :amount, type: Float
    # field :repair_date, type: Date
    # field for e-data.gov.ua
    field :repair_start_date, type: Date
    field :repair_end_date, type: Date
    field :edrpou_artist, type: String
    field :spending_units, type: String
    field :edrpou_spending_units, type: String

    field :warranty_date, type: Date
    field :description, type: String

    field :address, type: String
    field :address_to, type: String
    field :coordinates, type: Array

    before_save :set_end_date

    def set_end_date
      # If repair_end_date is empty fill it.
      if !self.repair_start_date.blank? && self.repair_end_date.blank?
        start_year = self.repair_start_date.year
        end_date = Date.new(y = start_year, m = 12, d = 31)
        self.repair_end_date = end_date
      end
    end

    def self.valid_repairs
      Repairing::Repair.collection.aggregate([
        {
            '$lookup'=> {
                from: 'repairing_layers',
                localField: 'layer_id',
                foreignField: '_id',
                as: 'layer'
            }
        },
        {
            '$match' =>{
                '$and' =>
                    [
                        {
                            # check if repair have layer
                            layer_id: {'$ne' => nil },
                            # check repair coordinates
                            coordinates: {'$ne' => nil},
                        }
                    ]
            }
        },
        {
            '$unwind'=> '$layer'
        },
        {
            '$project' => {
                'coordinates' => 1,
                'layer_id' => 1,
                'layer.repairing_category_id' => 1,
                'layer.town_id' => 1,
                'repair_date' => 1,

            }
        }
    ])
    end

  end
end