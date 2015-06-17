class Repairing::GeojsonBuilder

  def self.build_repair(repair)
    if repair.address_to.blank?
      build_repair_point(repair)
    else
      build_repair_path(repair)
    end
  end

  def self.build_repair_point(repair)
    {
        type: "Feature",
        geometry: {
            type: 'Point',
            coordinates: repair[:coordinates]
        },
        properties: {
            repair: "house",
            id: "#{repair[:id]}",
            title: "#{repair[:title]}",
            # description: repair[:description],
            address: "#{repair[:address]}",
            amount: "#{repair[:amount]}",
            repair_date: "#{repair[:repair_date]}"
        }
    }
  end

  def self.build_repair_path(repair)
    {
        type: "FeatureCollection",
        properties: {
          id: "#{repair[:id]}"
        },
        features: [
        # {
        #   type: "Feature",
        #   geometry: {
        #     type: 'Point',
        #     coordinates: repair[:coordinates][0]
        #   },
        #   properties: {
        #     repair: "street",
        #     id: "#{repair[:id]}",
        #     title: "#{repair[:title]}",
        #     # description: repair[:description],
        #     address: "#{repair[:address]} - #{repair[:address_to]}",
        #     amount: "#{repair[:amount]}",
        #     repair_date: "#{repair[:repair_date]}"
        #   }
        # },
        # {
        #     type: "Feature",
        #     geometry: {
        #       type: 'Point',
        #       coordinates: repair[:coordinates][repair[:coordinates].count - 1]
        #     },
        #     properties: {
        #       id: "#{repair[:id]}",
        #       title: "#{repair[:title]}",
        #       # description: repair[:description],
        #       address: "#{repair[:address_to]}",
        #       amount: "#{repair[:amount]}",
        #       repair_date: "#{repair[:repair_date]}"
        #     }
        #   },
          {
              type: "Feature",
              geometry: {
                type: 'LineString',
                coordinates: filterCoordinates(repair[:coordinates])
              },
              properties: {
                id: "#{repair[:id]}",
                title: "#{repair[:title]}",
                # description: repair[:description],
                address: "#{repair[:address]} - #{repair[:address_to]}",
                amount: "#{repair[:amount]}",
                repair_date: "#{repair[:repair_date]}"
              }
          }
        ]
    }
  end

  private

  def self.filterCoordinates coordinates
    return [] if coordinates.blank?

    n = coordinates.count
    filtered = []
    (0.. n - 2).step(n / 15 + 1) { |i| filtered << coordinates[i] }
    filtered << coordinates[n - 1]
  end

end
