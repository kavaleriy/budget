class ExportBudget
  include Mongoid::Document
  # has_one :calendar
  belongs_to :town
  belongs_to :user,class_name: 'User'

  validates :year,:title,:town, presence: true
  validates :year, numericality: { only_integer: true }
  validates :user, presence: true
  validates :town,presence: true
  # after_initialize :initial_content_template

  field :year, type: Integer
  field :title, type: String
  # field :template, type: String
  # field :town_id, type: String
  # field :header, type: String
  # field :footer, type: String
  field :content, type: String
  field :title_page,type: String

  scope :visible_to, -> (town,user){where(town: town,user: user)}

  def set_visual_place(number)
    "<div data-number=#{number} class ='visual_place disabled' style='
      background:#C0C0C0;
      width:100%;
      color:white;
      font-size:16px;
      text-align:center;'
      >Місце для вставки візуалізації <br>
      Натисніть на цей блок і виберіть візуалізацію
      </div> "
  end
  def initial_content_template

  end
end
