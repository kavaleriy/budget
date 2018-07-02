# frozen_string_literal: true

module Municipal
  # municipal enterprises in town
  class Enterprise
    include Mongoid::Document
    include Repairing::RepairsHelper

    REPORT_TYPE_1 = '1'
    REPORT_TYPE_2 = '2'
    REPORT_TYPE_3 = '3'

    include Mongoid::Timestamps
    field :edrpou, type: String
    field :title, type: String
    field :reporting_type, type: String
    field :debt, type: Integer
    field :actual_date, type: DateTime

    belongs_to :file, class_name: 'Municipal::EnterprisesList'
    belongs_to :town, class_name: 'Town'
    has_many :files, class_name: 'Municipal::EnterpriseFile', dependent: :destroy

    scope :by_town, ->(id) { where(town: id) }
    scope :by_type, ->(enterprise) {
      where(reporting_type: enterprise.reporting_type, town: enterprise.town)
    }

    before_save :check_and_emend_edrpou

    validates_presence_of :edrpou
    validates_uniqueness_of :edrpou, scope: :town

    def check_and_emend_edrpou
      self.edrpou = correct_edrpou(edrpou) if edrpou_length_short?(edrpou)
    end

    def other_files
      files.where(file_type: Municipal::EnterpriseFile::OTHER)
    end

    def self.report_type
      [
        { id: REPORT_TYPE_1, title: 'З' },
        { id: REPORT_TYPE_2, title: 'М' },
        { id: REPORT_TYPE_3, title: 'МС' }
      ]
    end
  end
end
