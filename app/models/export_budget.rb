class ExportBudget
  include Mongoid::Document
  belongs_to :town,class_name: 'Town'
  belongs_to :author,class_name: 'User'

  validates :year,:title,:town,:author, presence: true
  validates :year, numericality: { only_integer: true }

  field :year, type: Integer
  field :title, type: String
  field :pages,type: Hash
  # field :content, type: String
  # field :title_page,type: String
  # field :last_page,type: String

  scope :get_export_budget_by_town, ->(town){where(town:town).order(year: :desc)}

  def self.get_export_budgets_by_user user
    if user
      if user.is_admin?
        all.order(year: :desc)
      else
        where(author:user).order(year: :desc)
      end
    end
  end

  # after_initialize :set_default_pages, :if => :new_record?

  def user_can_edit?(user)
    # this function return user permissions for this export budget
    # if user nil he don't have any permissions
    # if user has role admin he have all permissions
    # else user have permissions only if user author this export budget
    have_permissions = false

    if user.nil?
      have_permissions
    elsif user.is_admin?
      !have_permissions
    elsif user.eql?(self.author)
      !have_permissions
    end
  end

    def set_default_pages
      self.pages = {
          :title_page => '',
          :content_page => '',
          :last_page => '',
          :content => {
              :public_budget => '',
              :city_budget => '',
              :where_is_my_money => '',
              :my_price => '',
              :indicates => '',
              :budget_influence => ''
          }
      }
    end
end
