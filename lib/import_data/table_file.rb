# frozen_string_literal: true

module ImportData
  # import data from file
  class TableFile
    def self.open_spreadsheet(file)
      require 'roo'

      case File.extname(file.original_filename).upcase
      when '.CSV' then Roo::CSV.new(file.path)
      when '.XLS'  then Roo::Spreadsheet.open(file.path, extension: :xls)
      when '.XLSX' then Roo::Excelx.new(file.path, file_warning: :ignore)
      else raise "Unknown file type: #{file.original_filename}"
      end
    end

  end
end
