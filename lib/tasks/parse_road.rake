namespace :parse_road do
  desc 'parse coordinate'

  task parse_osrm: :environment do
    # @coordinates = %i(22.268405 48.60814 22.268195 48.607666)
    # @coordinates = "{#{longitude}},{#{latitude}};{#{longitude}},{#{latitude}}"







    id = Repairing::Category.where(title: 'ремонт доріг та тротуарів').first.id

    arr = Repairing::Repair.where(repairing_category_id: id.to_s).to_a
    arr.each do |item|
      if item.coordinates.present? && item.coordinates.flatten.count == 4
        arr = item.coordinates.flatten
        @coordinates = "#{arr[0]},#{arr[1]};#{arr[2]},#{arr[3]}"

        @path = "https://router.project-osrm.org/route/v1/driving/#{@coordinates}?steps=true&overview=false&hints=;"
        uri = URI(@path)

        res = Net::HTTP.get_response(uri)

        # binding.pry

        q = JSON.parse(res.body)
        q['routes'].each do |route|
          route['legs'].each do |leg|
            binding.pry

            leg.steps
          end
          # @coordinates.push
          # item.coordinates.push(coordinaate['location'])
        end


      end



    end

    # def repair_coordinate
    #   if coordinates.first.kind_of?(Array)
    #     size = coordinates.size
    #     coordinates[size / 2]
    #   else
    #     coordinates
    #   end
    # end

    # @coordinates = "#{22.268405},#{48.60814};#{22.268195},#{48.607666}"

    # @path = "https://router.project-osrm.org/route/v1/driving/#{@coordinate_first};#{@coordinate_last}?overview=false&alternatives=true&steps=true&hints=;"
    # @path = "https://router.project-osrm.org/route/v1/driving/#{@coordinates}?overview=false&hints=;"
    # uri = URI(@path)

    # res = Net::HTTP.get_response(uri)

    # q = JSON.parse(res.body)
    # q['waypoints'].each do |coordinaate|
    #   # binding.pry
    #   coordinaate['location']
    # end

  end
end
