namespace :programs_remove_old_target_programs do
  task remove: :environment do
    Programs::TargetedProgram.each {|program| program.destroy}
  end
end