# frozen_string_literal: true

module Municipal
  # code status for enterprise
  class CodeStatus
    include Mongoid::Document
    include Mongoid::Enum

    field :code_number, type: String
    enum :status, %i[up some down]

    belongs_to :enterprise, class_name: 'Municipal::Enterprise'
  end
end
