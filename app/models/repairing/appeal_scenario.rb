module Repairing
  class AppealScenario
    include Mongoid::Document
    field :title, type: String
    field :text_form, type: String
    field :text_appeal, type: String
  end
end

