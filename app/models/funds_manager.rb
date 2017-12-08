class FundsManager
  require 'external_api'
  include Mongoid::Document
  field :edrpou, type: String
  field :title, type: String

  scope :by_edrpou, -> (edrpou){ where(edrpou: edrpou) }
  scope :by_town, -> (id){ where(town: id) }
  scope :by_towns, -> (towns){ where(:town.in => towns.split(",")) }
  # search manager by text from title
  scope :find_by_string, -> (text){ where(title: /#{text}/i) }
  scope :get_by_ids, lambda { |ids| where(:id.in => ids) }

  belongs_to :town

  before_validation :check_and_emend_edrpou, if: -> { edrpou.length == 7 }

  validates_presence_of :edrpou
  validates_uniqueness_of :edrpou, scope: :town

  def check_and_emend_edrpou
    self.edrpou = "0#{edrpou}"
  end

  # get title for town profile(portal of public finances)
  def pnaz
    title
  end

  def self.get_title_by_edrpou(edrpou)
    edr_data_arr = ExternalApi.edr_data(edrpou)
    title = edr_data_arr.blank? ? '' : edr_data_arr.first['officialName']
  end

  def self.import(file, town)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      # edrpou = by_edrpou(row['edrpou']).first || new
      edrpou = new

      edrpou.title = get_title_by_edrpou(row['edrpou'])

      edrpou.edrpou = row['edrpou']
      edrpou.town = town

      # create next if not valid(edrpou is already in the database)
      begin
        edrpou.save!
      rescue Mongoid::Errors::Validations => e
        next
      end
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
