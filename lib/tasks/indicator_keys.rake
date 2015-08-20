# encoding: utf-8

namespace :key_indicate_map do

  desc "Load IndicatorKeys from file"
  task :load => :environment do

    require 'roo'

    xls = Roo::CSV.new("db/indicator_keys.uk.csv", csv_options: {col_sep: ";"})

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
      key = KeyIndicateMap::IndicatorKey.new(row)
      key.save
    }

  end

end
