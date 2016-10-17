json.array!(@community_communities) do |community_community|
  json.extract! community_community, :id
  json.url community_community_url(community_community, format: :json)
end
