# frozen_string_literal: true

module ImportData
  # import municipal enterprises from file
  class ParseReport < TableFile
    CODE_LINE = 'Код рядка'
    END_REPORTING_PERIOD = 'На кінець звітного періоду' # for form_1
    REPORTING_PERIOD = 'За звітний період' # for form_2

    def self.import_form(file_path, file_record)
      spreadsheet = open_spreadsheet(file_path)
      header = spreadsheet.row(1).map(&:squish)
      value_header = file_record.file_type.eql?(Municipal::EnterpriseFile::FORM_1) ? END_REPORTING_PERIOD : REPORTING_PERIOD

      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        code_value = Municipal::CodeValue.new

        next if row[CODE_LINE].blank?
        # to_i for xls files
        code_value.code = row[CODE_LINE].to_i
        code_value.value = processing_value(row[value_header])
        code_value.enterprise_file = file_record.id
        code_value.save!
      end
    end

    def self.processing_value(value)
      # clear brackets and white spaces for negative value "( 4567 )"
      value.kind_of?(String) && value.include?('(') ? "-#{value.delete('() ')}" : value
    end
  end
end
