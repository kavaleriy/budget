require 'role_model'
class User
  include Mongoid::Document

  ROLES = %i[public_organisation city_authority central_authority municipal_enterprise state_enterprise region_authority].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include RoleModel

  scope :find_by_email, -> (email) {where(email: email)}
  before_create :lock_user

  # Setup accessible (or protected) attributes for your model
  field :locked
  def is_locked?
    self.locked == true || self.locked == '1'
  end

  field :name
  field :phone
  field :organisation
  field :town
  field :email
  field :password
  field :password_confirmation
  field :encrypted_password
  field :remember_me
  field :roles
  field :roles_mask

  field :sign_in_count, :type => Integer
  field :current_sign_in_at, :type => DateTime
  field :last_sign_in_at, :type => DateTime
  field :current_sign_in_ip
  field :last_sign_in_ip
  field :remember_created_at

  field :reset_password_token, type: String
  field :reset_password_sent_at, type: DateTime

  belongs_to :town_model, class_name: 'Town'

  validates :email, :town_model, presence: true
  # optionally set the integer attribute to store the roles in,
  # :roles_mask is the default
  roles_attribute :roles_mask

  # declare the valid roles -- do not change the order if you add more
  # roles later, always append them at the end!
  roles :admin, :guest, :editor, :public_organisation, :city_authority, :central_authority, :municipal_enterprise, :state_enterprise, :region_authority

  def town
    self.town_model.title
  end

  def to_s
    self.email
  end

  def region_admin?
    self.has_any_role?(:admin, :region_authority)
  end

  private

  def lock_user
    self.locked = true;
  end

end
