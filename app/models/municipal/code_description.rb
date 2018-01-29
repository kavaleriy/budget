# frozen_string_literal: true

module Municipal
  # code descriptions from guide filter file
  class CodeDescription
    include Mongoid::Document

    field :code, type: String
    field :title, type: String
    field :description, type: String
    field :unit, type: String
    field :publish, type: Boolean

    belongs_to :guide_filter, class_name: 'Municipal::GuideFilter'
  end
end
