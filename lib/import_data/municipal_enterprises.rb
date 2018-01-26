# frozen_string_literal: true

module ImportData
  # import municipal enterprises from file
  class MunicipalEnterprises < TableFile
    def self.import(file_path, file_record)
      spreadsheet = open_spreadsheet(file_path)
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        # enterprise = by_edrpou(row['edrpou']).first || new
        enterprise = Municipal::Enterprise.new

        # to_i for xls files
        enterprise.edrpou = row['Код ЄДРПОУ'].to_i
        enterprise.title = row['Назва підприємства']
        enterprise.reporting_type = row['Тип звітності']

        enterprise.file = file_record.id
        enterprise.town = file_record.town

        # create next if not valid(edrpou is already in the database)
        begin
          enterprise.save!
        rescue Mongoid::Errors::Validations => e
          next
        end
      end
    end

  end
end
