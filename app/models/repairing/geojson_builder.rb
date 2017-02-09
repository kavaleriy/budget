class Repairing::GeojsonBuilder

  def self.build_repair(repair)
    return if repair['coordinates'].blank? ||
        repair['coordinates'][0].nil? ||
        repair['coordinates'][1].nil?

    if repair['coordinates'][0].is_a?(Array) # && repair['coordinates'][0].length != 1
      build_repair_path(repair)
    else
      if repair['coordinates'][0].is_a?(Float) && repair['coordinates'][1].is_a?(Float)
        build_repair_point(repair)
      end
    end
  end

  def self.build_repair_point(repair)
    {
        type: "Feature",
        geometry: {
            type: 'Point',
            coordinates: repair['coordinates']
        },
        properties: {
            repair: "house",
        }.merge(extract_props(repair))
    }
  end

  def self.build_repair_path(repair)
    # coordinates =  repair['coordinates']
    coordinates =  repair['coordinates'].map.with_index do |point, i|
      # If not valid data in db
      # if point has only one coordinate
      if point.length == 1
        point << point[0]
      end
      # if point has coordinate as string
      point.map.with_index do |coord, j|
        if coord.to_i == 0    # coord is string
          # set coord from previous point
          # repair['coordinates'][i-1] ? repair['coordinates'][i-1][j] : coord
          return
        else
          coord
        end
      end
    end
    {
        type: "FeatureCollection",
        properties: {
          id: repair['_id'].to_s
        }.merge(extract_props(repair)),
        features: [
        {
          type: "Feature",
          geometry: {
            type: 'Point',
            coordinates: coordinates[ coordinates.count / 2 ]
          },
          properties: {
            id: repair['_id'].to_s,
            repair: "road",
            route: reduceCoordinatesCount(coordinates)
            # TODO: views/repairing/maps/_map.html.haml, 324 line
          }.merge(extract_props(repair)) # Ad hoc (add p_c_id field in this hash) for show road icon on repairing map
        },
        ]
    }

  end

  private

  def self.extract_props repair
    # category = Repairing::Category.find(repair.layer[:repairing_category_id]) if repair.layer && repair.layer[:repairing_category_id]

    # from maps controller we get BSON::Document in layer
    # from other place we get BSON::Object
    # if layer is object than set this layer as repair layer
    if repair['layer'].class.eql?( BSON::ObjectId )
      repair['layer'] = repair.layer
    end
    year = repair['layer']['year'] ? repair['layer']['year'] : :no_year # 'no_year' use in partial: _category_btns for select repairs on map
    {
        id: "#{repair['_id']}",
        p_c_id: "#{repair['layer']['repairing_category_id'] if repair['layer_id']}", #parent_category_id
        # category: "#{Repairing::Category.find(repair[:repairing_category_id]).title if repair[:repairing_category_id]}",
        # c_id: "#{repair[:repairing_category_id]}", #category_id
        t_id: "#{repair['layer']['town_id'] if repair['layer_id']}", #town_id
        # obj_owner: "#{repair[:obj_owner]}".gsub('\'', '`'),
        # title: "#{repair[:title]}".gsub('\'', '`'),
        # subject: "#{repair[:subject]}".gsub('\'', '`'),
        # work: "#{repair[:work]}",
        # description: repair[:description],
        # address: "#{repair[:address]}".gsub('\'', '`'),
        # amount: "#{repair[:amount]}",
        # repair_date: "#{repair[:repair_date].strftime("%m/%d/%Y") if repair[:repair_date]}",
        year: year,
        # warranty_date: "#{repair[:warranty_date].strftime("%m/%d/%Y") if repair[:warranty_date]}",
        # img: "#{category and category.img ? category.img.icon.url : ''}"
        status: "#{repair['layer']['status'] if repair['layer_id']}",
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
