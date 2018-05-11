# frozen_string_literal: true

module Municipal
  # code status for enterprise
  class CodeStatus
    include Mongoid::Document
    include Mongoid::Enum

    field :code, type: String
    field :reporting_type, type: String
    enum :status, %i[up some down]

    scope :by_type, ->(enterprise, type) { where(enterprise: enterprise, reporting_type: type) }

    belongs_to :enterprise, class_name: 'Municipal::Enterprise'

    def title
      Rails.cache.fetch("/code_statuses/title/#{code}", expires_in: 1.week) do
        Municipal::CodeDescription.where(code: code).first.try(:title)
      end
    end

    def publish
      false
    end
  end
end
