namespace :community do

  # only for presentation version! - Lugansk region

  desc "Load communities"
  task :load => :environment do

    hash = get_community_hash

    hash['features'].each do |f|
      koatuu = f['properties']['koatuu']
      next if koatuu.blank?

      puts koatuu

      town = Town.where(:koatuu => koatuu).first
      community = Community::Community.create({:town => town, :title => f['properties']['NAME_1'], :agree => f['properties']['agree'] ? true : false, :participants => f['properties']['participants']})

      geometry_type = f['geometry']['type']
      coordinates = []

      divider = 1

      case geometry_type
        when 'MultiPolygon'
          f['geometry']['coordinates'].each_with_index do |m, l|
            coordinates << []
            m[0].each_with_index do |c, i|
              coordinates[l] << get_community_coordinates(c[0], c[1]) if i % divider == 0
            end
          end
        when 'Polygon'
          f['geometry']['coordinates'][0].each_with_index do |c, i|
            coordinates << get_community_coordinates(c[0], c[1]) if i % divider == 0
          end
      end

      puts "#{f['geometry']['coordinates'][0].count} #{coordinates.count}"

      community.update(geometry_type: geometry_type, coordinates: [ coordinates ])
    end

  end

  private

  def get_community_coordinates(lat, lon)
    [lat.to_f.round(2), lon.to_f.round(2)]
  end

  def get_community_hash
    file = File.read('db/uk_community_areas.geojson')
    JSON.parse(file)
  end
end
