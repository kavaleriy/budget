require 'rubyXL'
class XlsWorker

  def self.create_xls_by_town(town)
    get_import_empty_town_table(town)
    # write_town_data_in_table(town,table[0])
  end

  private
  # @town_import_path = "#{Rails.root}/public/files/import_town.xlsx"

  def self.get_import_empty_town_table(town)
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.sheet_name = 'Town'

    town_table_header = %w{koatuu citizens house_holdings square}
    index = 0
    for item in town_table_header
      worksheet.add_cell(0, index, item)
      index = index + 1
    end

    row_num = 1
    worksheet.add_cell(row_num, 0, town.koatuu)
    unless town.counters.nil?
      worksheet.add_cell(row_num, 1, town.counters.citizens)
      worksheet.add_cell(row_num, 2, town.counters.house_holdings)
      worksheet.add_cell(row_num, 3, town.counters.square)
    end

    workbook.stream.read
    # table = Roo::Excelx.new(@town_import_path)
    # table.default_sheet = table.sheets.first
    # table
  end

  def self.write_town_data_in_table(town,out_table)
    row_num = 1
    out_table.add_cell(row_num, 0, town.koatuu)
    unless town.counters.nil?
      out_table.add_cell(row_num, 1, town.counters.citizens)
      out_table.add_cell(row_num, 2, town.counters.house_holdings)
      out_table.add_cell(row_num, 3, town.counters.square)
    end
    out_table
  end
end