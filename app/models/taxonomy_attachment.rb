class TaxonomyAttachment
  include Mongoid::Document

  embedded_in :taxonomy

  field :name, type: String
  field :description, type: String

end
