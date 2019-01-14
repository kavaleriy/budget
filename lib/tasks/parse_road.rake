namespace :parse_road do
  desc 'parse coordinate'

  task parse_osrm: :environment do

    id = Repairing::Category.where(title: 'ремонт доріг та тротуарів').first.id

    arr = Repairing::Repair.where(repairing_category_id: id.to_s).to_a
    # arr = Repairing::Repair.where(id: '5a1d5f592f21207606000024').to_a
    arr_count = arr.count
    arr.each do |item|
      if item.coordinates.present? && item.coordinates.flatten.count >= 4
        # @start = [48.60814, 22.268405]
        # @end = [48.607666, 22.268195]
        @start = []
        @end = []
        if item.coordinates.first.count >= 2
          if item.coordinates.first.count == 2
            @start = [item.coordinates.first.flatten[0], item.coordinates.first.flatten[1]]
          else
            arr_2 = []
            item.coordinates.first.each do |c|
              unless arr_2.include? c.to_i
                arr_2 << c.to_i
                @start << c
              end
            end
          end
        end

        if item.coordinates.last.count >= 2
          if item.coordinates.last.count == 2
            @end = [item.coordinates.last.flatten[0], item.coordinates.last.flatten[1]]
          else
            arr_2 = []
            item.coordinates.last.each do |c|
              unless arr_2.include? c.to_i
                arr_2 << c.to_i
                @end << c
              end
            end
          end
        end

        @coordinates = "#{@start[1]},#{@start[0]};#{@end[1]},#{@end[0]}"
        @path = "https://router.project-osrm.org/route/v1/driving/#{@coordinates}?steps=true&overview=false&hints=;"

        uri = URI(@path)
        res = retry_request(uri, 0.1)
        @all_coordinate = []

        q = JSON.parse(res.body)
        q['routes'].each do |route|
          route['legs'].each do |leg|
            leg['steps'].each do |step|
              step['intersections'].each do |location|
                @all_coordinate.push(location['location'].reverse)
              end
            end
          end
        end

        if @all_coordinate.present?
          tmp = [@start] + @all_coordinate + [@end]
          item.update(coordinates: tmp)
        end
      end

      puts "#{arr_count -= 1}) Done: #{item}"
    end
  end

  def retry_request(uri, sleep_s)
    again = true
    sleeper = sleep_s
    res = nil

    while again do

      res = Net::HTTP.get_response(uri)
      if res.header.code != '200'
        sleep sleeper
      else
        break
      end
      sleeper = sleeper + sleep_s
    end
    return res
  end
end
