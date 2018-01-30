# frozen_string_literal: true

module Municipal
  # code values from enterprise file
  class CodeValue
    include Mongoid::Document

    field :code, type: String
    field :value, type: Integer

    belongs_to :enterprise_file, class_name: 'Municipal::EnterpriseFile'

    scope :by_file, ->(id) { where(enterprise_file: id) }

    def title
      Rails.cache.fetch("/code_values/title/#{code}", expires_in: 1.week) do
        Municipal::CodeDescription.find_by(code: code).try(:title)
      end
    end

  end
end
