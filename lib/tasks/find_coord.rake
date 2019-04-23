namespace :find_coord do

  desc 'Find coordinates by addresses'
  task coord: :environment do
    require 'roo'
    require 'csv'

    xls = Roo::Excelx.new("file_name.xlsx")
    xls.default_sheet = xls.sheets.first
    cols = []
    xls.first_column.upto(xls.last_column) { |col|
      cols << xls.cell(1, col).to_s
    }
    # we can check row on presence or validate
    #
    rows = []
    2.upto(xls.last_row) do |line|
      row = {}
      xls.first_column.upto(xls.last_column ) do |col|
        if col == 2
          address = xls.cell(line,1).to_s
          coordinates = RepairingGeocoder.calc_coordinates(address, '')
          coord_str = "#{coordinates[0]}, #{coordinates[1]}"
          row[xls.cell(1, col)] = coord_str
        else
          row[xls.cell(1, col)] = xls.cell(line,col).to_s
        end
      end
      puts "#{row}"
      rows << row
    end
    full_data = { :rows => rows, :cols => cols }

    CSV.open('file_name.csv', 'wb', headers: true, col_sep: ';') do |csv|
      csv << ['Address', 'coordinates']
      full_data[:rows].each do |row|
        csv << [row['адреса'], row['координати']]
      end
    end
  end
end
