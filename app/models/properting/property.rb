require 'ext/string'
module Properting
  class Property
    include Mongoid::Document
    include Mongoid::Timestamps
    include Properting::PropertiesHelper

    # TODO:Check this concern for properting!!!!!!!!!!!!!!
    extend RepairingLayerUpload

    scope :last_updated, -> {order("updated_at DESC").limit(1)}
    scope :by_layer, -> (layer_id) {where(layer: layer_id)}
    belongs_to :layer, class_name: 'Properting::Layer', touch: true
    validates :layer, presence: true

    belongs_to :properting_category, class_name: 'Properting::Category', dependent: :nullify
    embeds_many :photos, class_name: 'Properting::Photo'

    field :obj_owner, type: String
    field :subject, type: String
    field :work, type: String
    field :amount, type: Float
    field :property_start_date, type: Date
    field :property_end_date, type: Date
    field :edrpou_artist, type: String
    field :spending_units, type: String
    field :edrpou_spending_units, type: String
    field :prozzoro_id, type: String
    field :prozzoro_inner_id, type: String

    field :warranty_date, type: String
    field :description, type: String

    field :address, type: String
    field :address_to, type: String
    field :coordinates, type: Array

    # index({ coordinates: "2d" }, { min: -200, max: 200 })

    before_validation :check_and_emend_edrpou
    before_validation :geocode, on: :update, if: ->(obj) { obj.check_address }

    validates :spending_units, :edrpou_spending_units, :address, :amount, presence: true
    # validate :validate_coords

    before_save :set_end_date

    def check_and_emend_edrpou
      self.edrpou_artist         = correct_edrpou(edrpou_artist)          if edrpou_length_short?(edrpou_artist)
      self.edrpou_spending_units = correct_edrpou(edrpou_spending_units)  if edrpou_length_short?(edrpou_spending_units)
    end

    def set_end_date
      if !self.property_start_date.blank? && self.property_end_date.blank?
        start_year = self.property_start_date.year
        end_date = Date.new(y = start_year, m = 12, d = 31)
        self.property_end_date = end_date
      end
    end

    def validate_coords
      # TODO
      # if coordinates[0] and coordinates[0].kind_of?(Array)
      #   coordinates.each do |coords|
      #     check_coords_array(coords)
      #   end
      # else
      #   check_coords_array(coordinates)
      # end
    end

    # TODO:Check this concern for properting!!!!!!!!!!!!!!
    def geocode
      self.coordinates = RepairingGeocoder.calc_coordinates(address, address_to)
    end

    def check_address
      (address.present?) && (!coordinates.present? || address_changed? || address_to_changed?)
    end

    def town_emails
      layer.town.present_emails
    end

    # def permit_appeal?
    #   # layer.status.eql?('fact') && layer.town.permit_emails
    #   layer.town.permit_emails
    # end

    def property_coordinate
      if coordinates.first.kind_of?(Array)
        size = coordinates.size
        coordinates[size / 2]
      else
        coordinates
      end
    end

    private

    def check_coords_array(coords)

    end

    def self.import(layer, filepath, child_category)
      properties_arr = read_table_from_file(filepath)[:rows]

      properties_arr.each do |property|
        property_hash = build_property_hash(property)

        coordinates = property['координати']
        coordinates1 = property['координати1']

        property_hash[:coordinates] =
            if coordinates1.blank?
              if coordinates.blank?
                nil
              else
                coordinates.split(',').map(&:to_f)
              end
            else
              [coordinates.split(',').map(&:to_f), coordinates1.split(',').map(&:to_f)]
            end

        layer_property = self.create(property_hash)
        layer_property.layer = layer
        layer_property.properting_category = child_category if child_category.present?

        layer_property.save(validate: false)
      end
    end


    def self.expiration_date(d_string)
      d_string.try(:to_date)
    rescue ArgumentError
      # ad hoc
      # Example: "31.06.2017" - not valid date because June has 30 days
      # return Sat, 01 Jul 2017 ("30.06.2017")
      d_string.try(:to_time).try(:to_date).yesterday
    end

    def self.build_property_hash(property)

      start_property_date = expiration_date(property['дата початку ремонту'])
      end_property_date = expiration_date(property['дата закінчення ремонту'])

      {
          spending_units: property['розпорядник бюджетних коштів'],
          edrpou_spending_units: property['єдрпоу розпорядника бюджетних коштів'],

          subject: property['назва об\'єкту'],

          address: property['адреса'],
          address_to: property['адреса1'],

          work: property['опис робіт'],
          amount: property['вартість'],

          property_start_date: start_property_date,
          property_end_date: end_property_date,
          warranty_date: property['гарантія'],

          prozzoro_id: property['id закупівлі'],
          prozzoro_inner_id: property['id закупівлі внутрішнє'],

          obj_owner: property['виконавець'],
          edrpou_artist: property['єдрпоу виконавця'],

          description: property['додаткова інформація'],
      }
    end

    def self.property_json_by_town(town)

      # HERE WAS TROUBLE WITH ROUT
      Rails.cache.fetch("/properting/as_json/#{town}/#{town_updated(town)}", expires_in: 1.hours) do
        propertings = Properting::Layer.valid_layers_with_properties
        geo_jsons = []

        #TODO: change logic for default date(1970)
        last_updated = Time.new('1970-01-01')
        last_year_data = ''

        # if town not empty filter array by town
        propertings.select! { |key, _value| key['town_id'].to_s.eql?(town) } unless town.blank?

        propertings.each do |layer, properties|
          last_year_data = layer['year'] if layer['year'].present? && (last_year_data < layer['year'])

          properties.each do |property|
            if property['updated_at'].present? && last_updated < property['updated_at']
              last_updated = property['updated_at']
            end
            property['layer'] = {}
            property['layer']['town_id'] = layer['town_id'].to_s
            property['layer']['status'] = layer['status'] || :plan
            property['layer']['year'] = layer['year']
            property['layer']['properting_category_id'] = layer['properting_category_id'].to_s
            property['properting_category_id'] = property['properting_category_id'].to_s

            property_json = Properting::GeojsonBuilder.build_property(property)
            geo_jsons << property_json if property_json
          end
        end
        {
          'type' => 'FeatureCollection',
          'features' => geo_jsons,
          'last_updated' => last_updated,
          'last_year_data' => last_year_data
        }
      end
    end

    def self.town_updated(id)
      Town.find(id).updated_at if id.present?
    end
  end
end
