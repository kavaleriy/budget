require 'roo'
class XlsWorker

  def self.create_xls_by_town(town)
    table = get_import_empty_town_table
    write_town_data_in_table(town,table)
  end

  private
  @town_import_path = "#{Rails.root}/public/files/import_town.xlsx"

  def self.get_import_empty_town_table
    Roo::Excelx.new(@town_import_path)
  end

  def self.write_town_data_in_table(town,out_table)
    row = out_table.row(2)
    row[0] = town.koatuu
    unless town.counters.nil?
      row[1] = town.counters.citizens
      row[2] = town.counters.house_holdings
      row[3] = town.counters.square
    end
    out_table
  end
end