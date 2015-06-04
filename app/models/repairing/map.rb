class Repairing::Map
  include Mongoid::Document

  field :title, type: String
  field :town, type: String

  has_many :repairs, :class_name => 'Repairing::Repair', autosave: true, :dependent => :destroy
end
