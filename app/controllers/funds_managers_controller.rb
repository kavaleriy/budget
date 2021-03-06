class FundsManagersController < ApplicationController
  layout 'application_admin'
  helper_method :sort_column, :sort_direction
  before_action :access_user?
  before_action :set_funds_manager, only: [:destroy, :edit, :update]

  respond_to :html

  def index
    @funds_managers = current_user.admin? ? FundsManager.all : FundsManager.by_town(current_user.town_model)
    @funds_managers = @funds_managers.by_towns(params['town_select'])           unless params['town_select'].blank?
    @funds_managers = @funds_managers.find_by_string(params['query'])           unless params['query'].blank?
    @funds_managers = @funds_managers.order(sort_column + ' ' + sort_direction) if params[:sort]
    @funds_managers = @funds_managers.page(params[:page]).per(30)

    # respond_with(@funds_managers)
    respond_to do |format|
      format.js
      format.html
    end
  end

  # def show
  #   respond_with(@funds_manager)
  # end

  def new
    @funds_manager = FundsManager.new
    respond_with(@funds_manager)
  end

  def edit
  end

  def create
    require 'external_api'
    @funds_manager = FundsManager.new(funds_manager_params)
    @funds_manager.town = get_town_by_role(params[:town])
    @funds_manager.title = FundsManager.get_title_by_edrpou(params[:funds_manager][:edrpou])

    respond_to do |format|
      if @funds_manager.save
        format.html { redirect_to funds_managers_path, notice: t('funds_managers.messages.created')}
      else
        format.html { render action: 'new' }
        format.json { render json: @funds_manager.errors, status: :unprocessable_entity }
      end
    end
  end

  def import
    town = get_town_by_role(params[:town])
    FundsManager.import(params[:file], town)
    redirect_to funds_managers_path, notice: t('funds_managers.messages.uploaded')

  rescue Roo::Base::TypeError
    message = [t('invalid_format')]
    message << t('repairing.layers.check_xlsx_format')
    respond_with_error_message(message)
  rescue => e
    message = [t('repairing.layers.update.error')]
    message << "#{e}"
    respond_with_error_message(message)
  end

  def respond_with_error_message(message)
    respond_to do |format|
      format.html { redirect_to :back, alert:  message }
    end
  end

  def update
    @funds_manager.town = get_town_by_role(params[:town])
    @funds_manager.update(funds_manager_params)
    redirect_to funds_managers_path, notice:  t('funds_managers.messages.updated')
  end

  def multiple_destroy
    FundsManager.get_by_ids(params[:ids]).destroy_all

    redirect_to :back
  end

  def destroy
    @funds_manager.destroy
    respond_with(@funds_manager)
  end

  private

    def get_town_by_role(town)
      current_user.admin? ? town : current_user.town_model
    end

    def access_user?
      unless current_user && current_user.has_any_role?(:admin, :city_authority, :central_authority, :municipal_enterprise, :state_enterprise)
        redirect_to root_url, alert: t('export_budgets.notice_access')
      end
    end

    def sort_column
      FundsManager.fields.keys.include?(params[:sort]) ? params[:sort] : 'title'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
    end

    def set_funds_manager
      @funds_manager = FundsManager.find(params[:id])
    end

    def funds_manager_params
      params.require(:funds_manager).permit(:edrpou, :title)
    end
end
