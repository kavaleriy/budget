class Modules::PartnersCategory
  include Mongoid::Document
  field :title, type: String
  field :alias_str, type: String

  scope :by_alias_str, -> (as){ where(alias_str: as )}

  validates :title, :alias_str, presence: true
  validates :alias_str, uniqueness: true

  has_many :modules_partners, :class_name => 'Modules::Partner'


end
