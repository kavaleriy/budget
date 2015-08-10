# encoding: utf-8

namespace :uk_areas do

  desc "Load area polygons"
  task :parse => :environment do
    hash = get_hash()

    hash['features'].each do |f|
      koatuu = f['properties']['koatuu']
      next if koatuu.blank?

      puts koatuu

      town = Town.find_by koatuu: koatuu

      geometry_type = f['geometry']['type']
      coordinates = []

      divider = 10

      case geometry_type
        when 'MultiPolygon'
          f['geometry']['coordinates'].each_with_index do |m, l|
            coordinates << []
            m[0].each_with_index do |c, i|
              coordinates[l] << get_coordinates(c[0], c[1]) if i % divider == 0
            end
          end
        when 'Polygon'
          f['geometry']['coordinates'][0].each_with_index do |c, i|
            coordinates << get_coordinates(c[0], c[1]) if i % divider == 0
          end
      end

      puts "#{f['geometry']['coordinates'][0].count} #{coordinates.count}"

      town.update(geometry_type: geometry_type, coordinates: [ coordinates ])
    end
  end

  def get_coordinates(lat, lon)
    [lat.to_f.round(2), lon.to_f.round(2)]
  end

  def get_hash

    file = File.read('db/uk_map_areas.geojson')
    data_hash = JSON.parse(file)
    data_hash
  end
end