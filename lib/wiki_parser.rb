class WikiParser

  # Work ONLY if Town belongs to area or town
  # TODO: create method for get wiki info for village

  def self.get_wiki_town_info(title)
    # API wiki page hash key value if page doesn't exist (-1)
    wiki_page_empty_result = '-1'

    # Wiki-URL town page
    # data_url = "https://uk.wikipedia.org/w/api.php?action=parse&prop=text&format=json&page="
    data_url = "https://uk.wikipedia.org/w/api.php?format=json&action=query&prop=revisions&rvprop=content&rvsection=0&rvparse&titles="

    # encode String to ASCII and concat URL
    uri = URI(data_url + URI.encode("#{title}"))

    # get info from uri
    response = Net::HTTP.get(uri)
    # get needed data from hash with template (template for town)
    result = JSON.parse(response)['query']['pages']

    # data control for existing page in wikipedia
    if result.first[0].eql?(wiki_page_empty_result)
      false
    else
      result.first[1]['revisions'].first['*'].html_safe
    end

  end

end