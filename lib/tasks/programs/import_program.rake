namespace :programs_import_program do
  task import_program: :environment do
    filepath = "#{Rails.public_path}/files/target_programs/import/import_template.xlsx"
    program = Programs::TargetProgram.import(filepath)
    program.save
  end
end