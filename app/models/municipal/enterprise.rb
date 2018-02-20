# frozen_string_literal: true

module Municipal
  # municipal enterprises in town
  class Enterprise
    include Mongoid::Document

    REPORT_TYPE_1 = '1'
    REPORT_TYPE_2 = '2'
    REPORT_TYPE_3 = '3'

    include Mongoid::Timestamps
    field :edrpou, type: String
    field :title, type: String
    field :reporting_type, type: String

    belongs_to :file, class_name: 'Municipal::EnterprisesList'
    belongs_to :town, class_name: 'Town'
    has_many :files, class_name: 'Municipal::EnterpriseFile', dependent: :destroy

    scope :by_town, ->(id) { where(town: id) }

    validates_presence_of :edrpou
    validates_uniqueness_of :edrpou, scope: :town

    def other_files
      files.where(file_type: Municipal::EnterpriseFile::OTHER)
    end

    def self.by_type
      # test query
      # to do refactor
      where(reporting_type: REPORT_TYPE_1)
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
