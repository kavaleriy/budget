# frozen_string_literal: true

module Municipal
  # upload files for enterprise
  class EnterpriseFile
    include Mongoid::Document
    require 'carrierwave/mongoid'

    include Mongoid::Timestamps
    mount_uploader :file, FileUploader
    # used for update record with uploader
    # skip_callback :update, :before, :store_previous_model_for_file

    field :file_type, type: String
    field :year, type: Integer


    belongs_to :enterprise, class_name: 'Municipal::Enterprise'

    validates_presence_of :enterprise, :file_type, :year, :file

    def self.type_files
      [
        { id: 1, title: I18n.t('enterprise_files.type_files.form_1') },
        { id: 2, title: I18n.t('enterprise_files.type_files.form_2') },
        { id: 3, title: I18n.t('enterprise_files.type_files.other') }
      ]
    end

  end
end
