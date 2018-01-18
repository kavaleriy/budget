# frozen_string_literal: true

module Municipal
  # upload files for enterprise
  class CodeValue
    include Mongoid::Document

    field :code, type: String
    field :value, type: Integer

    belongs_to :enterprise_file, class_name: 'Municipal::EnterpriseFile'
  end
end
