class Programs::TargetProgram
  include Mongoid::Document
  field :title, type: String
  field :years, type: Hash
  field :p_id,type: String
  field :description,type: String
  field :responsible,type: String

  has_many :sub_programs,class_name: 'Programs::TargetProgram',foreign_key: 'p_id'
  has_many :indicators,class_name: 'Programs::Indicator'

  belongs_to :author,class_name: 'User'
  belongs_to :town, class_name: 'Town'

  scope :get_main_programs,-> {where(p_id: nil)}

  validates :title,:responsible,:description,:town,presence: true


  def set_author(author)
    self.author ||= author
  end

end
