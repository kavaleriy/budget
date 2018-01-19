# frozen_string_literal: true

module Municipal
  # upload files for enterprise
  class EnterpriseFile
    include Mongoid::Document
    require 'carrierwave/mongoid'

    FORM_1 = '1'.freeze
    FORM_2 = '2'.freeze
    OTHER = '3'.freeze

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

  end
end
