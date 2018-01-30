# frozen_string_literal: true

module Municipal
  # code values from enterprise file
  class CodeValue
    include Mongoid::Document

    field :code, type: String
    field :value, type: Integer

    belongs_to :enterprise_file, class_name: 'Municipal::EnterpriseFile'

    scope :by_file, ->(id) { where(enterprise_file: id) }

  end
end
