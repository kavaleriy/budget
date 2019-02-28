require 'ext/string'
module Properting
  class Property
    include Mongoid::Document
    include Mongoid::Timestamps
    include Properting::PropertiesHelper
    include StatusBtn

    # TODO: Check this concern for properting!!!!!!!!!!!!!!
    extend RepairingLayerUpload

    scope :last_updated, -> { order('updated_at DESC').limit(1) }
    scope :by_layer, ->(layer_id) { where(layer: layer_id) }
    belongs_to :layer, class_name: 'Properting::Layer', touch: true
    validates :layer, presence: true

    belongs_to  :properting_category, class_name: 'Properting::Category', dependent: :nullify
    embeds_many :photos, class_name: 'Properting::Photo'

    field :obj_owner, type: String
    field :obj_address, type: String
    field :obj_name, type: String
    field :obj_desc, type: String
    field :obj_characteristic, type: String

    field :balance_holder_field, type: String
    field :category, type: String

    field :edrpou_balance_holder, type: String
    field :edrpou_renter, type: String

    field :coordinates, type: Array
    field :renter_name, type: String
    field :legal_status, type: String
    field :deal_number, type: String
    field :basis_contract, type: String

    field :contract_start_date, type: Date
    field :contract_end_date, type: Date

    field :last_rent_charge, type: String
    field :purpose, type: String
    field :evaluation_date, type: Date
    field :expert_obj_cost, type: String
    field :rental_rate, type: String
    field :prozzoro_id, type: String

    # Внизу тепер кожному полю має бути точна назва з документу

    # index({ coordinates: "2d" }, { min: -200, max: 200 })

    before_validation :check_and_emend_edrpou
    before_validation :geocode, on: :update, if: ->(obj) { obj.check_address }

    # validates :spending_units, :edrpou_spending_units, :address, :amount, presence: true
    # validate :validate_coords

    before_save :set_end_date

    def check_and_emend_edrpou
      self.edrpou_balance_holder  = correct_edrpou(edrpou_balance_holder) if edrpou_length_short?(edrpou_balance_holder)
      self.edrpou_renter          = correct_edrpou(edrpou_renter)         if edrpou_length_short?(edrpou_renter)
    end

    def set_end_date
      if contract_start_date.present? && contract_end_date.blank?
        start_year = contract_start_date.year
        end_date = Date.new(y = start_year, m = 12, d = 31)
        self.property_end_date = end_date
      end
    end

    # TODO: Check this concern for properting!!!!!!!!!!!!!!
    def geocode
      self.coordinates = RepairingGeocoder.calc_coordinates(obj_address, address_to)
    end

    # def check_address
    #   obj_address.present? && (coordinates.blank? || address_changed? || address_to_changed?)
    # end

    def town_emails
      layer.town.present_emails
    end

    # def permit_appeal?
    #   # layer.status.eql?('fact') && layer.town.permit_emails
    #   layer.town.permit_emails
    # end

    def property_coordinate
      if coordinates.first.is_a?(Array)
        size = coordinates.size
        coordinates[size / 2]
      else
        coordinates
      end
    end

    private

    def self.import(filepath, child_category, current_user, properting_layer_params)
      properties_arr = read_table_from_file(filepath)[:rows]

      properties_arr.each_with_index do |property, index|
        property_hash = build_property_hash(property)
        coordinates = property['координати']
        coordinates1 = []

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

        layer_property = create(property_hash)
        properting_category = Properting::Category.find_by(title: layer_property.category)
        layer_property.properting_category_id = properting_category.id
        status = status_btn(layer_property.legal_status)

        layer = Properting::Layer.where(properting_category_id: properting_category.id, status: status).first_or_create(properting_layer_params)
        layer.owner_id = current_user.id
        layer.properties_file = properting_layer_params[:properties_file]
        layer.save

        layer_property.layer = layer
        layer_property.properting_category = child_category if child_category.present?
        layer_property.save(validate: false)
      end
      FileUtils.rm(filepath) if filepath.present?
    end

    def self.expiration_date(d_string)
      d_string.try(:to_date)
    rescue ArgumentError
      # ad h
      # Example: "31.06.2017" - not valid date because June has 30 days
      # return Sat, 01 Jul 2017 ("30.06.2017")
      d_string.try(:to_time).try(:to_date).yesterday
    end

    def self.build_property_hash(property)
      contract_start_date = expiration_date(property['дата укладання договору оренди'])
      contract_end_date = expiration_date(property['дата закінчення договору оренди'])
      evaluation_date = expiration_date(property['дата проведення оцінки'])

      {
        obj_owner: property['балансоутримувач'],
        edrpou_balance_holder: property['код єдрпоу балансоутримувача'],
        balance_holder_field: property['сфера балансоутримувача'],
        obj_address: property['адреса об\'єкту'],
        obj_name: property['назва об\'єкту'],
        obj_desc: property['опис об\'єкту'],
        category: property['категорія'],
        renter_name: property['найменування користувача\\орендаря'],
        edrpou_renter: property['єдрпоу орендаря'],
        legal_status: property['правовий статус'],
        deal_number: property['№ договору'],
        basis_contract: property['підстава укладання договору оренди'],
        contract_start_date: property['дата початку оренди'],
        contract_end_date: property['дата закінчення оренди'],
        evaluation_date: property['дата проведення оцінки'],
        purpose: property['цільове призначення'],
        obj_characteristic: property['характеритиска об\'єкту (площа)'],
        expert_obj_cost: property['вартість об\'єкту за експертною оцінкою'],
        rental_rate: property['орендна ставка'],
        last_rent_charge: property['останнє нарахування орендної плати, грн'],
        prozzoro_id: property['id prozorro.sales']
      }
    end

    def self.property_json_by_town(town)
      # HERE WAS TROUBLE WITH ROUT
      Rails.cache.fetch("/properting/as_json/#{town}/#{town_updated(town)}", expires_in: 1.hour) do
        propertings = Properting::Layer.valid_layers_with_properties
        geo_jsons = []

        # TODO: change logic for default date(1970)
        last_updated = Time.new('1970-01-01')
        last_year_data = ''

        # if town not empty filter array by town
        propertings.select! { |key, _value| key['town_id'].to_s.eql?(town) } if town.present?

        propertings.each do |layer, properties|
          last_year_data = layer['year'] if layer['year'].present? && (last_year_data < layer['year'])

          properties.each do |property|
            if property['updated_at'].present? && last_updated < property['updated_at']
              last_updated = property['updated_at']
            end
            # binding.pry
            property['layer'] = {}
            property['layer']['town_id'] = layer['town_id'].to_s
            property['layer']['status'] = layer['status'] || :plan
            property['layer']['year'] = layer['year']
            property['layer']['properting_category_id'] = layer['properting_category_id'].to_s
            property['properting_category_id'] = layer['properting_category_id'].to_s

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
