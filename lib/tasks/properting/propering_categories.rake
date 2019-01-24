namespace :propering_categories do

  desc "Load propering categories"
  task :load => :environment do
    require 'roo'

    xls = Roo::CSV.new("db/propering_categories.uk.csv", csv_options: {col_sep: ";"})

    cols = []
    xls.first_column.upto(xls.last_column) { |col|
      cols << xls.cell(1, col).to_s
    }

    rows = []
    2.upto(xls.last_row) do |line|
      row = {}

      next if xls.respond_to?(:font) and xls.font(line, 1).bold?

      xls.first_column.upto(xls.last_column ) do |col|
        row[xls.cell(1, col)] = xls.cell(line,col).to_s
      end
      rows << row
    end

    rows.each{|row|
      if row['work'].blank?
        category = Properting::Category.new({:title => row['category'], :icon => row['icon'], :color => row['color']})
      else
        parent = Properting::Category.where(:title => row['category']).first
        category = Properting::Category.new({:title => row['work'], :icon => row['icon'], :color => row['color']})
        category.category = parent
      end
      category.save
    }
  end

  desc "Add locale field with 'uk' value"
  task add_locale_field: :environment do
    Repairing::Category.where(locale: nil).update_all(locale: 'uk')
  end

end
