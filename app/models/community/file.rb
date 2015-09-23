class Community::File
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String

  has_many :community_communities, :class_name => 'Community::Community', dependent: :destroy, :autosave => true

  mount_uploader :file, CommunityFileUploader
  validates_presence_of :file, message: 'Потрібно вибрати Файл'

  def import hash

    hash['features'].each do |f|
      koatuu = f['properties']['koatuu']
      next if koatuu.blank?

      puts koatuu

      town = Town.where(:koatuu => koatuu).first
      community = Community::Community.where(:town => town, :title => f['properties']['NAME_1']).first
      community.destroy unless community.nil?
      community = Community::Community.create({:town => town, :title => f['properties']['NAME_1'], :community_file_id => self.id, :agree => f['properties']['agree'] ? true : false, :participants => f['properties']['participants']})

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

end