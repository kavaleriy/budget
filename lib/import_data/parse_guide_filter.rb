# frozen_string_literal: true

module ImportData
  # import code descriptions from file
  class ParseGuideFilter < TableFile
    def self.import(file_path, file_record)
      spreadsheet = open_spreadsheet(file_path)
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        code_desc = Municipal::CodeDescription.new

        next if row['Код рядка'].blank?

        # to_i for xls files
        code_desc.code = row['Код рядка'].to_i
        code_desc.title = row['Назва коду']
        code_desc.description = row['Опис коду']
        code_desc.unit = row['Одиниці виміру']
        code_desc.guide_filter = file_record.id
        code_desc.save!
      end
    end
  end
end
