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

    scope :by_enterprise, ->(ent) { where(enterprise: ent) }
    scope :by_year, ->(year) { where(year: year) }
    scope :by_file_type, ->(type) { where(file_type: type) }
    scope :by_file_name, ->(text) { where(file: /.*#{text}.*/) }

    belongs_to :enterprise, class_name: 'Municipal::Enterprise'
    belongs_to :owner, class_name: 'User'
    has_many :code_values, class_name: 'Municipal::CodeValue', dependent: :destroy

    # validates_presence_of :enterprise
    # validates_uniqueness_of scope: [:file_type, :enterprise]

    def town
      enterprise.try(:town).try(:title)
    end

    def self.type_files
      [
        { id: FORM_1, title: I18n.t('enterprise_files.type_files.form_1') },
        { id: FORM_2, title: I18n.t('enterprise_files.type_files.form_2') },
        { id: OTHER, title: I18n.t('enterprise_files.type_files.form_3') }
      ]
    end

    def self.type_codes
      [
        { id: FORM_1, title: I18n.t('guide_filters.type_codes.form_1') },
        { id: FORM_2, title: I18n.t('guide_filters.type_codes.form_2') },
        { id: OTHER, title: I18n.t('guide_filters.type_codes.form_3') }
      ]
    end

    def self.by_town(town)
      enterprise_ids = Municipal::Enterprise.where(town: town).pluck(:id)
      where(:enterprise_id.in => enterprise_ids)
    end

  end
end
