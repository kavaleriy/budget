json.array!(@programs_target_programs) do |programs_target_program|
  json.extract! programs_target_program, :id
  json.url programs_target_program_url(programs_target_program, format: :json)
end
