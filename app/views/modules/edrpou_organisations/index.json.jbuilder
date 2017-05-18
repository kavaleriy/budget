json.array!(@modules_edrpou_organisations) do |modules_edrpou_organisation|
  json.extract! modules_edrpou_organisation, :id, :edrpou
  json.url modules_edrpou_organisation_url(modules_edrpou_organisation, format: :json)
end
