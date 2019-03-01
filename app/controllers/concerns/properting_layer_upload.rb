module PropertingLayerUpload
  extend ActiveSupport::Concern

  def read_table_from_file(path)
    require 'roo'

    case File.extname(path).upcase
      when '.CSV'
        read_csv_xls Roo::CSV.new(path, csv_options: {col_sep: ";"})
      when '.XLS'
        xls = Roo::Excel.new(path)
        xls.default_sheet = xls.sheets.first
        read_csv_xls xls
      when '.XLSX'
        xls = Roo::Excelx.new(path)
        xls.default_sheet = xls.sheets.first
        read_csv_xls xls
      else '.DBF'
      read_dbf DBF::Table.new(path)

    end
  end

  def read_csv_xls(xls)
    cols = []
    xls.first_column.upto(xls.last_column) { |col|
      cols << xls.cell(1, col).to_s
    }

    rows = []
    2.upto(xls.last_row) do |line|
      row = {}

      # next if xls.respond_to?(:font) and xls.font(line, 1).bold?

      xls.first_column.upto(xls.last_column ) do |col|
        row[xls.cell(1, col)] = xls.cell(line,col).to_s
      end
      rows << row
    end

    { :rows => rows, :cols => cols }
  end
  def open_file(param_file)
    uploaded_io = param_file
    File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end
    Rails.root.join('public', 'uploads', uploaded_io.original_filename)
  end
end
