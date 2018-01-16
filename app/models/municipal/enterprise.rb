# frozen_string_literal: true

module Municipal
  class Enterprise
    include Mongoid::Document

    include Mongoid::Timestamps
    field :edrpou, type: String
    field :title, type: String

    belongs_to :file, class_name: 'Municipal::EnterprisesFile'
    belongs_to :town, class_name: 'Town'

    scope :by_town, ->(id) { where(town: id) }

    validates_presence_of :edrpou
    validates_uniqueness_of :edrpou, scope: :town

    def self.import(file_path, file_record)
      spreadsheet = open_spreadsheet(file_path)
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        # enterprise = by_edrpou(row['edrpou']).first || new
        enterprise = new

        # to_i for xls files
        enterprise.edrpou = row['Код ЄДРПОУ'].to_i
        enterprise.title = row['Назва підприємства']

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

    def self.open_spreadsheet(file)
      case File.extname(file.original_filename).upcase
        when '.CSV'  then Roo::CSV.new(file.path)
        when '.XLS'  then Roo::Spreadsheet.open(file.path, extension: :xls)
        when '.XLSX' then Roo::Excelx.new(file.path, file_warning: :ignore)
        else raise "Unknown file type: #{file.original_filename}"
      end
    end

  end
end
