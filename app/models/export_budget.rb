class ExportBudget
  include Mongoid::Document
  belongs_to :town,class_name: 'Town'
  belongs_to :user,class_name: 'User'

  validates :year,:title,:town,:user, presence: true
  validates :year, numericality: { only_integer: true }


  field :year, type: Integer
  field :title, type: String
  field :content, type: String
  field :title_page,type: String

  scope :visible_to, -> (town,user){where(user: user)}

end
