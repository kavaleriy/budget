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
    if get_username_name(user).blank?
      if get_username_from_email(user).length > 10
        (get_username_from_email(user)[0,9] + "&hellip;").html_safe
      else
        get_username_from_email(user)
      end
    else
      if get_username_name(user).length > 10
        (get_username_name(user)[0,9] + "&hellip;").html_safe
      else
        get_username_name(user)
      end
    end
  end

end