class Properting::GeojsonBuilder

  def self.build_property(property)
    return if property['coordinates'].blank? ||
      property['coordinates'][0].nil? ||
      property['coordinates'][1].nil?

    # Check latitude and longitude with '.length' , Del this check when added 2d indexes
    if property['coordinates'][0].is_a?(Array) && property['coordinates'][0].length != 1
      build_property_path(property)
    else
      if property['coordinates'][0].is_a?(Float) && property['coordinates'][1].is_a?(Float)
        build_property_point(property)
      end
    end
  end

  def self.build_property_point(property)
    {
        type: "Feature",
        geometry: {
            type: 'Point',
            coordinates: property['coordinates']
        },
        properties: {
          property: "house",
        }.merge(extract_props(property))
    }
  end

  def self.build_property_path(property)
    {
      type: "FeatureCollection",
      properties: {
        id: property['_id'].to_s
      }.merge(extract_props(property)),
      features: [
        {
          type: "Feature",
          geometry: {
            type: 'Point',
            coordinates: property['coordinates'][ property['coordinates'].count / 2 ]
          },
          properties: {
            id: property['_id'].to_s,
            property: "road",
            route: reduceCoordinatesCount(property['coordinates'])
            # TODO: views/properting/maps/_map.html.haml, 324 line
          }.merge(extract_props(property))
        },
      ]
    }
  end

  private

  def self.extract_props property

    # from maps controller we get BSON::Document in layer
    # from other place we get BSON::Object
    if property['layer'].class.eql?( BSON::ObjectId )
      property['layer'] = property.layer
    end
    year = property['layer']['year'] ? property['layer']['year'] : :no_year
    {
        id: "#{property['_id']}",
        p_c_id: "#{property['layer']['properting_category_id_id'] if property['layer_id']}", #parent_category_id
        c_id: "#{property['properting_category_id']}" , #child_category_id
        t_id: "#{property['layer']['town_id'] if property['layer_id']}", #town_id
        year: year,
        status: "#{property['layer']['status'] if property['layer_id']}",
    }
  end

  def self.reduceCoordinatesCount coordinates
    return [] if coordinates.blank?

    n = coordinates.count
    filtered = []
    (0.. n - 2).step(n / 15 + 1) { |i| filtered << coordinates[i] }
    filtered << coordinates[n - 1]
  end
end
