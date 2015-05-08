module UsersHelper
  def self.is_admin? user
    true if user && user.has_role?(:admin)
  end
end
