class XlsParser < RubyXL::Parser

  def self.get_table_hash(worksheet)
    row_number = 0
    res = []
    worksheet.each do |row|
      unless row_number == 0
        cell_number = 0
        row_res = {}
        row && row.cells.each do |cell|
          val = cell && cell.value
          field_name = worksheet[0][cell_number].value unless worksheet[0][cell_number].nil?

          row_res[field_name] = val
          row_res.delete_if {|key, value| key.nil?}

          cell_number = cell_number + 1
        end
        res << row_res
      end
      row_number = row_number + 1
    end
    res
  end

  def self.get_workbook(path)
    RubyXL::Parser.parse(path)
  end
end