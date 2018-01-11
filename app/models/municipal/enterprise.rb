require 'file_size_validator'

class Municipal::Enterprise
  include Mongoid::Document
  include Mongoid::Timestamps

  field :edrpou, type: String
  field :title, type: String

  scope :by_town, ->(id) { where(town: id) }

  # belongs_to :owner, class_name: 'User'
  belongs_to :town, class_name: 'Town'

  validates_presence_of :edrpou
  validates_uniqueness_of :edrpou, scope: :town

  def self.import(file, town)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      # edrpou = by_edrpou(row['edrpou']).first || new
      edrpou = new

      edrpou.edrpou = row['Код ЄДРПОУ']
      edrpou.title = row['Назва підприємства']

      edrpou.town = town

      # create next if not valid(edrpou is already in the database)
      begin
        edrpou.save!
      rescue Mongoid::Errors::Validations => e
        next
      end
    end
  end

end
