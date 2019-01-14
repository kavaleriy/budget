namespace :parse_road do
  desc 'parse coordinate'

  task parse_osrm: :environment do
    binding.pry
    @coordinate_first = '22.268405,48.60814'
    @coordinate_last = '22.268195,48.607666'
    path = "https://router.project-osrm.org/route/v1/driving/#{coordinate_first};#{coordinate_last}?overview=false&alternatives=true&steps=true&hints=;"
    uri = URI(path)
    params = { id: @coordinate_first,
               appid: @coordinate_last }

    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    JSON.parse(res.body)


  end
end
