#encoding: utf-8

namespace :budget_files do

  require "#{Rails.root}/app/controllers/concerns/budget_file_upload.rb"
  include BudgetFileUpload

  desc "Re-Load data from budget files"
  task :reload, [:taxonomy_id] => :environment  do |t, args|
    Taxonomy.find_by(id: args.taxonomy_id).budget_files.each do |file|
      puts "#{file.title} - #{file.path}"
      if File.exist?(file.path)
        table = read_table_from_file file.path

        file.import table
        file.save
      end
    end
  end

end
