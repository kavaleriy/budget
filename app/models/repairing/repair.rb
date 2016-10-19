require 'ext/string'
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
    field :prozzoro_id, type: String

    field :warranty_date, type: String
    field :description, type: String

    field :address, type: String
    field :address_to, type: String
    field :coordinates, type: Array

    validates :spending_units, :edrpou_spending_units, :address, :amount, presence: true
    validate :validate_coords

    before_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? and !obj.coordinates.present?}
    before_save :set_end_date

    def set_end_date
      # If repair_end_date is empty fill it.
      if !self.repair_start_date.blank? && self.repair_end_date.blank?
        start_year = self.repair_start_date.year
        end_date = Date.new(y = start_year, m = 12, d = 31)
        self.repair_end_date = end_date
      end
    end

    def validate_coords
      if coordinates[0].kind_of?(Array)
        coordinates.each do |coords|
          check_coords_array(coords)
        end
      else
        check_coords_array(coordinates)
      end
    end

    def geocode
      self.coordinates =  Geocoder.coordinates(address)
    end

    private

    def check_coords_array(coords)
      errors.add(I18n.t('repairing.repairs.coords.wrong_length')) unless coords.size.eql?(2)
      if coords[0].kind_of?(String) && coords[1].kind_of?(String)
        errors.add(I18n.t('repairing.repairs.coords.wrong_type')) unless coords[0].valid_by_float? || coords[1].valid_by_float?
      else
        errors.add(I18n.t('repairing.repairs.coords.wrong_type')) unless coords[0].kind_of?(Float) || coords[1].kind_of?(Float)
      end

    end
  end
end