class Repairing::GeojsonBuilder

  def self.build_repair_point(repair)
    {
        type: "Feature",
        geometry: {
            type: "Point",
            coordinates: repair[:coordinates]
        },
        properties: {
            id: "#{repair[:id]}",
            title: repair[:title],
            # description: repair[:description],
            address: repair[:street],
            amount: repair[:amount],
            repair_date: repair[:repair_date],
        }
    }
  end

end
