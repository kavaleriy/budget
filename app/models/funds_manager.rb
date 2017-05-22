class FundsManager
  require 'external_api'
  include Mongoid::Document
  field :edrpou, type: String

  scope :by_edrpou, -> (edrpou){ where(edrpou: edrpou) }
  scope :by_town, -> (id){ where(town: id) }

  belongs_to :town

  validates_presence_of :edrpou

  def title
    edr_data_arr = ExternalApi.edr_data(self.edrpou)
    # @edr_data = edr_data_arr.first['officialName'] unless edr_data_arr.nil?

    unless edr_data_arr.blank?
      @edr_data = edr_data_arr.first['officialName']
    else
      'Дані відсутні'
    end
  end

  def self.import(file, town)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      edrpou = by_edrpou(row['edrpou']).first || new
      edrpou.edrpou = row['edrpou']
      edrpou.town = town
      edrpou.save!
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename).upcase
      when '.CSV'  then Roo::CSV.new(file.path)
      when '.XLS'  then Roo::Excel.new(file.path)
      when '.XLSX' then Roo::Excelx.new(file.path, file_warning: :ignore)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end

end
