namespace :community do

  # only for presentation version! - Lugansk region

  desc "Load communities"
  task :load => :environment do
    puts "agreed communities"
    %w(4420955100 4423155100 4423355100).each{|koatuu|
      puts koatuu
      town = Town.where(:koatuu => koatuu).first
      Community::Community.create({:agree => true, :town => town})
    }
    puts "other communities"
    %w(4425455100 4420955700 4424055400 4424010100 4421655400 4421610100 4412500000 4423355300 4425110100 4422555100 4420655100 4422855100 4410161400 4424855100 4412900000 4412170500 4411800000).each{|koatuu|
      puts koatuu
      town = Town.where(:koatuu => koatuu).first
      Community::Community.create({:agree => false, :town => town})
    }
  end

  desc "Load area polygons"
  task :parse_coordinates => :environment do
    hash = get_community_hash()

    hash['features'].each do |f|
      koatuu = f['properties']['koatuu']
      next if koatuu.blank?

      puts koatuu

      community = Community::Community.where(:town => Town.where(:koatuu => koatuu).first).first
      unless community.nil?   # delete after adding villages to koatuu
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
  end

  private

  def get_community_coordinates(lat, lon)
    [lat.to_f.round(2), lon.to_f.round(2)]
  end

  def get_community_hash
    file = File.read('db/uk_community_areas.geojson')
    data_hash = JSON.parse(file)
    data_hash
  end
end
