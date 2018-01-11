module ParseFiles
  extend ActiveSupport::Concern

  def open_spreadsheet(file)
    case File.extname(file.original_filename).upcase
      when '.CSV'  then Roo::CSV.new(file.path)
      when '.XLS'  then Roo::Excel.new(file.path)
      when '.XLSX' then Roo::Excelx.new(file.path, file_warning: :ignore)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end

end