class Indicate::Taxonomy
  include Mongoid::Document

  field :title, type: String
  field :town, type: String

end
