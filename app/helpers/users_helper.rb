module UsersHelper
  def self.is_admin? user
    true if user && user.has_role?(:admin)
  end

  def user_town(user)
    town = user.town_model
    town.title unless town.nil?
  end
end
