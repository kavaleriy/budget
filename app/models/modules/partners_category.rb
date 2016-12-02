class Modules::PartnersCategory
  include Mongoid::Document
  field :title, type: String
  field :alias_str, type: String

  scope :by_alias_str, -> (as){ where(alias_str: as )}

  validates :title, :alias_str, presence: true
  validates :alias_str, uniqueness: true
  before_validation :check_alias, if: ->(obj){ !obj.new_record? and obj.alias_str_changed? }
  has_many :modules_partners, :class_name => 'Modules::Partner'

  # if alias was changed in not new object
  # it's important, because alias can't be change
  def check_alias
    self.alias_str = self.alias_str_was
  end

end
