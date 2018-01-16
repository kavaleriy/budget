# frozen_string_literal: true

module Municipal
  class Enterprise
    include Mongoid::Document

    include Mongoid::Timestamps
    field :edrpou, type: String
    field :title, type: String

    belongs_to :file, class_name: 'Municipal::EnterprisesFile'
    belongs_to :town, class_name: 'Town'

    scope :by_town, ->(id) { where(town: id) }

    validates_presence_of :edrpou
    validates_uniqueness_of :edrpou, scope: :town

  end
end
