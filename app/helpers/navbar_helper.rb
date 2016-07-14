module NavbarHelper

  def get_username_from_email(user)
    user.email.split('@').first
  end

  def get_domain_from_email(user)
    user.email.split('@').last
  end

  def get_username_name(user)
    user.name
  end

  def show_username_or_emailname(user)
    # Check current user name for empty(nil? & empty?)
    name = get_username_name(user).blank? ? get_username_from_email(user) : get_username_name(user)
    # Check current user name length
    (name.length > 3) ? (name[0,9] + "&hellip;").html_safe : name
  end

end