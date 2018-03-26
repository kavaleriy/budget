require 'ext/string'
module Repairing
  class Repair
    include Mongoid::Document
    include Mongoid::Timestamps

    extend RepairingLayerUpload

    scope :last_updated, -> {order("updated_at DESC").limit(1)}
    scope :by_layer, -> (layer_id) {where(layer: layer_id)}
    belongs_to :layer, class_name: 'Repairing::Layer', touch: true
    validates :layer, presence: true

    belongs_to :repairing_category, class_name: 'Repairing::Category', dependent: :nullify
    embeds_many :photos, class_name: 'Repairing::Photo'

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
      self.edrpou_artist         =  "0#{edrpou_artist}"          if edrpou_artist.try(:length) == 7
      self.edrpou_spending_units =  "0#{edrpou_spending_units}"  if edrpou_spending_units.try(:length) == 7
    end

    def set_end_date
      # If repair_end_date is empty fill it.
      if !self.repair_start_date.blank? && self.repair_end_date.blank?
        start_year = self.repair_start_date.year
        end_date = Date.new(y = start_year, m = 12, d = 31)
        self.repair_end_date = end_date
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

    def geocode
      self.coordinates = RepairingGeocoder.calc_coordinates(address, address_to)
    end

    def check_address
      (address.present?) && (!coordinates.present? || address_changed? || address_to_changed?)
    end

    def town_emails
      layer.town.emails
    end

    def permit_town_emails?
      layer.town.permit_emails
    end

    private

    def check_coords_array(coords)
      # errors.add(I18n.t('repairing.repairs.coords.wrong_length')) unless coords.size.eql?(2)
      # if coords[0].kind_of?(String) && coords[1].kind_of?(String)
      #   errors.add(I18n.t('repairing.obj_ownerrepairs.coords.wrong_type')) unless coords[0].valid_by_float? || coords[1].valid_by_float?
      # else
      #   errors.add(I18n.t('repairing.repairs.coords.wrong_type')) unless coords[0].kind_of?(Float) || coords[1].kind_of?(Float)
      # end

    end

    def self.import(layer, filepath, child_category)
      repairs_arr = read_table_from_file(filepath)[:rows]

      repairs_arr.each do |repair|
        repair_hash = build_repair_hash(repair)

        coordinates = repair['координати']
        coordinates1 = repair['координати1']

        repair_hash[:coordinates] =
            if coordinates1.blank?
              if coordinates.blank?
                nil
              else
                coordinates.split(',').map(&:to_f)
              end
            else
              [coordinates.split(',').map(&:to_f), coordinates1.split(',').map(&:to_f)]
            end

        layer_repair = self.create(repair_hash)
        layer_repair.layer = layer
        layer_repair.repairing_category = child_category if child_category.present?

        layer_repair.save(validate: false)
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

    def self.build_repair_hash(repair)
      # this function build hash for repair model
      # get two parameters repair hash and coordinates array
      # first of all convert repair start and end date to date
      # after that build and return hash

      start_repair_date = expiration_date(repair['дата початку ремонту'])
      end_repair_date = expiration_date(repair['дата закінчення ремонту'])

      {
          spending_units: repair['розпорядник бюджетних коштів'],
          edrpou_spending_units: repair['єдрпоу розпорядника бюджетних коштів'],

          subject: repair['назва об\'єкту'],

          address: repair['адреса'],
          address_to: repair['адреса1'],

          work: repair['опис робіт'],
          amount: repair['вартість'],

          repair_start_date: start_repair_date,
          repair_end_date: end_repair_date,
          warranty_date: repair['гарантія'],

          prozzoro_id: repair['id закупівлі'],
          prozzoro_inner_id: repair['id закупівлі внутрішнє'],

          obj_owner: repair['виконавець'],
          edrpou_artist: repair['єдрпоу виконавця'],

          description: repair['додаткова інформація'],
      }
    end

    def self.repair_json_by_town(town)
      Rails.cache.fetch("/repairings/as_json/#{town}/#{town_updated(town)}", expires_in: 1.hours) do
        repairings = Repairing::Layer.valid_layers_with_repairs
        geo_jsons = []

        # set default last update date of repair
        #TODO: change logic for default date(1970)
        last_updated = Time.new('1970-01-01')
        last_year_data = ''

        # if town not empty filter array by town
        repairings.select! { |key, _value| key['town_id'].to_s.eql?(town) } unless town.blank?

        repairings.each do |layer, repairs|
          last_year_data = layer['year'] if layer['year'].present? && (last_year_data < layer['year'])

          repairs.each do |repair|
            if repair['updated_at'].present? && last_updated < repair['updated_at']
              last_updated = repair['updated_at']
            end

            repair['layer'] = {}
            repair['layer']['town_id'] = layer['town_id'].to_s
            repair['layer']['status'] = layer['status'] || :plan
            repair['layer']['year'] = layer['year']
            repair['layer']['repairing_category_id'] = layer['repairing_category_id'].to_s
            repair['repairing_category_id'] = repair['repairing_category_id'].to_s

            repair_json = Repairing::GeojsonBuilder.build_repair(repair)
            geo_jsons << repair_json if repair_json
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
