json.array!(@repairing_appeal_scenarios) do |repairing_appeal_scenario|
  json.extract! repairing_appeal_scenario, :id, :title, :text_form, :text_appeal
  json.url repairing_appeal_scenario_url(repairing_appeal_scenario, format: :json)
end
