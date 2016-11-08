class TownIndicatorsGeojsonBuilder

  def self.build(town)
    if town.get_level == :area
      build_area town
    else
      build_point town
    end
  end

  def self.build_area(town)
    unless town[:coordinates].blank?
      {
          type: "Feature",
          geometry: {
              type: town[:geometry_type],
              coordinates: town[:coordinates]
          },
          properties: {
              id: "#{town[:id]}",
              title: town.title,
              level:town.get_level,
              indicators:town.get_key_indicators
          }
      }
    end
  end

  def self.build_point(town)
    unless town[:coordinates].blank?
      {
          type: "Feature",
          geometry: {
              type: 'Point',
              coordinates: town[:coordinates]
          },
          properties: {
              id: "#{town[:id]}",
              title: town.title,
              level:town.get_level,
              indicators:town.get_key_indicators
          }
      }
    end
  end

end
