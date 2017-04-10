require 'ext/string'
module Repairing
  class Repair
    include Mongoid::Document
    include Mongoid::Timestamps

    extend RepairingLayerUpload

    scope :last_updated, -> {order("updated_at DESC").limit(1)}
    scope :by_layer, -> (layer_id) {where(layer: layer_id)}
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
    field :prozzoro_inner_id, type: String

    field :warranty_date, type: String
    field :description, type: String

    field :address, type: String
    field :address_to, type: String
    field :coordinates, type: Array

    # index({ coordinates: "2d" }, { min: -200, max: 200 })

    validates :spending_units, :edrpou_spending_units, :address, :amount, presence: true
    # validate :validate_coords

    before_validation :geocode, if: ->(obj){ (obj.address.present?) && (!obj.coordinates.present? || obj.address_changed? || obj.address_to_changed?) }, on: :update
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

    private

    def check_coords_array(coords)
      # errors.add(I18n.t('repairing.repairs.coords.wrong_length')) unless coords.size.eql?(2)
      # if coords[0].kind_of?(String) && coords[1].kind_of?(String)
      #   errors.add(I18n.t('repairing.obj_ownerrepairs.coords.wrong_type')) unless coords[0].valid_by_float? || coords[1].valid_by_float?
      # else
      #   errors.add(I18n.t('repairing.repairs.coords.wrong_type')) unless coords[0].kind_of?(Float) || coords[1].kind_of?(Float)
      # end

    end

    def self.import(layer, filepath)
      repairs_arr = read_table_from_file(filepath)[:rows]

      repairs_arr.each do |repair|
        repair_hash = build_repair_hash(repair)

        coordinates = repair['Координати']
        coordinates1 = repair['Координати1']

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

        layer_repair.repairing_category = Repairing::Category.where(title: repair['Опис робіт']).first

        layer_repair.save!
      end
    end

    def self.build_repair_hash(repair)
      # this function build hash for repair model
      # get two parameters repair hash and coordinates array
      # first of all convert repair start and end date to date
      # after that build and return hash

      start_repair_date = repair['Дата початку ремонту'] ? repair['Дата початку ремонту'].to_date : nil
      end_repair_date = repair['Дата закінчення ремонту'] ? repair['Дата закінчення ремонту'].to_date : nil

      {
          spending_units: repair['Розпорядник бюджетних коштів'],
          edrpou_spending_units: repair['ЄДРПОУ розпорядника бюджетних коштів'],

          subject: repair['Назва об\'єкту'],

          address: repair['Адреса'],
          address_to: repair['Адреса1'],

          work: repair['Опис робіт'],
          amount: repair['Вартість'],

          repair_start_date: start_repair_date,
          repair_end_date: end_repair_date,
          warranty_date: repair['Гарантія'],

          prozzoro_id: repair['ID закупівлі'],
          prozzoro_inner_id: repair['ID закупівлі внутрішнє'],

          obj_owner: repair['Виконавець'],
          edrpou_artist: repair['ЄДРПОУ виконавця'],

          description: repair['Додаткова інформація'],
      }
    end
    def self.repair_json_by_town(town)
      repairings = Repairing::Layer.valid_layers_with_repairs
      geo_jsons = []

      # set default last update date of repair
      #TODO: change logic for default date(1970)
      last_updated = Time.new('1970-01-01')

      # if town not empty filter array by town
      repairings.select!{ |key,value| key['town_id'].to_s.eql?(town) } unless town.blank?
      repairings.each { |layer,repairs|
        repairs.each do |repair|
          unless repair['updated_at'].nil?
            if  last_updated < repair['updated_at']
              last_updated = repair['updated_at']
            end
          end
          repair['layer'] = {}
          repair['layer']['town_id'] = layer['town_id'].to_s
          repair['layer']['status'] = layer['status'] || :plan
          repair['layer']['year'] = layer['year']
          repair['layer']['repairing_category_id'] = layer['repairing_category_id'].to_s

          repair_json = Repairing::GeojsonBuilder.build_repair(repair)
          geo_jsons << repair_json if repair_json
        end

      }

      {
          'type' => 'FeatureCollection',
          'features' => geo_jsons,
          'last_updated' => last_updated
      }
    end
  end
end