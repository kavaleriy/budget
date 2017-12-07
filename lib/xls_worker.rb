require 'rubyXL'
class XlsWorker

  def self.create_xls_by_town(town)
    get_import_empty_town_table(town)
    # write_town_data_in_table(town,table[0])
  end

  def self.create_xls_with_e_data(data)
    filling_e_data_file(data)
  end

  private
  # @town_import_path = "#{Rails.root}/public/files/import_town.xlsx"

  def self.get_import_empty_town_table(town)
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.sheet_name = 'Town'

    town_table_header = %w{koatuu citizens house_holdings square}

    build_header(worksheet, town_table_header)

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

  def self.filling_e_data_file(data)
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.sheet_name = 'Search_e_data'

    data_table_header = [
        I18n.t('modules.classifier.search_e_data.sum'),
        I18n.t('modules.classifier.search_e_data.payer'),
        I18n.t('modules.classifier.search_e_data.recipt'),
        I18n.t('modules.classifier.search_e_data.purpose'),
        I18n.t('modules.classifier.search_e_data.date')
    ]

    build_header(worksheet, data_table_header)

    unless data.blank?
      data.each_with_index do |line, i|
        row_num = i + 1
        worksheet.add_cell(row_num, 0, line['amount'])
        worksheet.add_cell(row_num, 1, line['payer_name'])
        worksheet.add_cell(row_num, 2, line['recipt_name'] + " " + line['recipt_edrpou'])
        worksheet.add_cell(row_num, 3, line['payment_details'])
        worksheet.add_cell(row_num, 4, line['trans_date'].split('T')[0])
      end
    end

    workbook.stream.read
  end

  def self.build_header(worksheet, header_list)
    # add_cell(row_num, col_num, string)
    header_list.each_with_index { |item, i| worksheet.add_cell(0, i, item) }
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