class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :cancan_hack

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => t('application.auth_error') + "#{exception.message}"
  end


  # dealing with mass assignment
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :password, :current_password, :town) }
  end

  private

  def cancan_hack
    return if request.get?

    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"

    params[resource] &&= send(method) if respond_to?(method, true)

    method = "budget_file_params"
    params[resource] &&= send(method) if respond_to?(method, true)

    method = "vtarnay_module5_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  before_action :set_locale
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    { locale: I18n.locale }.merge options
  end

end
