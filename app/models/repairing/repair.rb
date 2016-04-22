module Repairing
  class Repair
    include Mongoid::Document

    belongs_to :layer, class_name: 'Repairing::Layer'

    belongs_to :repairing_category, :class_name => 'Repairing::Category', :dependent => :nullify

    field :title, type: String

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
    #

    field :warranty_date, type: Date

    field :description, type: String


    field :address, type: String
    field :address_to, type: String

    field :coordinates, type: Array

    # include Geocoder::Model::Mongoid
    # geocoded_by :address               # can also be an IP address
    #
    # after_validation :geocode          # auto-fetch coordinates
    def get_round_coordinates(coord_arr)
      # binding.pry
        [coord_arr[0].round(4),coord_arr[1].round(4)]
    end

    def get_repairing_category_title
      res = ''
      res = self.repairing_category.title unless self.repairing_category.nil?
      res
    end
  end

end