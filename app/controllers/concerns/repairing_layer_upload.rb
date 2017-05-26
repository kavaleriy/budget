module RepairingLayerUpload
  extend ActiveSupport::Concern
  def read_csv_xls(xls)
    cols = []
    xls.first_column.upto(xls.last_column) { |col|
      cols << downcase_header(xls.cell(1, col))
    }

    rows = []
    2.upto(xls.last_row) do |line|
      row = {}
      xls.first_column.upto(xls.last_column ) do |col|
        row[downcase_header(xls.cell(1, col))] = xls.cell(line,col).to_s.strip
        # row.transform_keys! { |key| key.strip }
      end
      rows << row
    end

    { :rows => rows, :cols => cols }
  end

  def read_table_from_file path
    require 'roo'

    xls = Roo::Excelx.new(path)
    xls.default_sheet = xls.sheets.first
    read_csv_xls xls
  end

  def downcase_header(str)
    str.mb_chars.downcase.to_s.strip
  end

end