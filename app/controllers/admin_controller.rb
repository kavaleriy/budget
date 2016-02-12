class AdminController < ApplicationController

  load_and_authorize_resource
  before_action :check_admin_permission

  def check_admin_permission
    unless current_user && current_user.admin?
      binding.pry
      session[:return_to] = request.env['REQUEST_URI']
      redirect_to new_user_session_path
    end
  end



end
