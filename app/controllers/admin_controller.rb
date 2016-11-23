class AdminController < ApplicationController
  layout 'application_admin'

  # load_and_authorize_resource
  before_action :check_admin_permission

  def check_admin_permission
    unless current_user && current_user.admin?
      # session[:return_to] = request.env['REQUEST_URI']
      # redirect_to new_user_session_path
      redirect_to root_path
    end
  end
end
