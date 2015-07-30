class TownGeojsonBuilder

  def self.build_town(town)
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
              documents_count:town.documentation_documents.count,
          }
      }
    end
  end

end
