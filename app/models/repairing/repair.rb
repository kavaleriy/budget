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

  end

end