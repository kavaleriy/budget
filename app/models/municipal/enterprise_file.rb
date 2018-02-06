# frozen_string_literal: true

module Municipal
  # upload files for enterprise
  class EnterpriseFile
    include Mongoid::Document
    require 'carrierwave/mongoid'

    FORM_1 = '1'
    FORM_2 = '2'
    OTHER = '3'

    include Mongoid::Timestamps
    mount_uploader :file, FileUploader
    # used for update record with uploader
    # skip_callback :update, :before, :store_previous_model_for_file

    field :file_type, type: String
    field :year, type: Integer

    belongs_to :enterprise, class_name: 'Municipal::Enterprise'
    belongs_to :owner, class_name: 'User'
    has_many :code_values, class_name: 'Municipal::CodeValue', dependent: :destroy

    validates_presence_of :enterprise, :file_type, :year, :file

    def self.type_files
      [
        { id: FORM_1, title: I18n.t('enterprise_files.type_files.form_1') },
        { id: FORM_2, title: I18n.t('enterprise_files.type_files.form_2') },
        { id: OTHER, title: I18n.t('enterprise_files.type_files.form_3') }
      ]
    end

    def self.by_town(town)
      enterprise_ids = Municipal::Enterprise.where(town: town).pluck(:id)
      files = where(:enterprise_id.in => enterprise_ids)
    end

    def self.reporting_chart(enterprise_id, code)
      file_type = code.first.eql?(FORM_1) ? FORM_1 : FORM_2
      files = where(enterprise: enterprise_id, file_type: file_type)
      desc = Municipal::CodeDescription.where(code: code).first.try(:description)
      chart = {}

      chart[code] = {} if chart[code].nil?
      chart[code]['years'] = {} if chart[code]['years'].nil?
      chart[code]['desc'] = {} if chart[code]['desc'].nil?
      chart[code]['desc'] = desc

      files.each do |file|
        year = file.year
        value = file.code_values.where(code: code).first.value

        chart[code]['years'][year] = value
      end
      chart
    end

  end
end
