class ApplicationController < ActionController::Base
  include SessionsHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :cancan_hack

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => t('application.auth_error') + "#{exception.message}"
  end


  # dealing with mass assignment
  before_filter :configure_permitted_parameters, if: :devise_controller?


  rescue_from Mongoid::Errors::DocumentNotFound, :with => :record_not_found

  def record_not_found
    redirect_to :action => :index, notice: t('record_not_found')
  end

  def after_sign_in_path_for(resource_or_scope)
    case resource_or_scope
      when :user, User
        store_location = session[:return_to]
        clear_stored_location
        (store_location.nil?) ? "/" : store_location.to_s
      else
        super
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :current_password, :phone, :organisation, :town) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :password, :current_password, :phone, :organisation, :town) }
  end

  def read_table_from_file path
    require 'roo'

    case File.extname(path).upcase
      when '.CSV'
        read_csv_xls Roo::CSV.new(path, csv_options: {col_sep: ";"})
      when '.XLS', '.XLSX'
        xls = Roo::Excelx.new(path)
        xls.default_sheet = xls.sheets.first
        read_csv_xls xls
      when '.DBF'
        read_dbf DBF::Table.new(path)
    end
  end

  def read_dbf(dbf)
    cols = dbf.columns.map {|c| c.name}

    rows = dbf.map do |rec|
      row = {}
      cols.each { |col|
        row[col] = rec[col]
      }
      row
    end

    { :rows => rows, :cols => cols }
  end

  def read_csv_xls(xls)
    cols = []
    xls.first_column.upto(xls.last_column) { |col|
      cols << xls.cell(1, col).to_s
    }

    rows = []
    2.upto(xls.last_row) do |line|
      row = {}
      xls.first_column.upto(xls.last_column ) do |col|
        row[xls.cell(1, col)] = xls.cell(line,col).to_s
      end
      rows << row
    end

    { :rows => rows, :cols => cols }
  end

  private

  def cancan_hack
    return if request.get?

    resource = controller_path.sub('/', '_').singularize.to_sym

    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)

    method = "budget_file_params"
    params[resource] &&= send(method) if respond_to?(method, true)

    resource = controller_name.sub('/', '_').singularize.to_sym

    method = "#{resource}_params"
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
