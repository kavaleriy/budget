class Repairing::Map
  include Mongoid::Document

  field :title

  has_many :repairs, :class_name => 'Repairing::Repair', autosave: true, :dependent => :destroy
end
