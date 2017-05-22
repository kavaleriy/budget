class FundsManagersController < ApplicationController
  layout 'application_admin'
  before_action :access_user?
  before_action :set_funds_manager, only: [:show, :edit, :update, :destroy]
  # skip_before_action :check_admin_permission

  respond_to :html

  def index
    @funds_managers = FundsManager.all
    respond_with(@funds_managers)
  end

  def show
    respond_with(@funds_manager)
  end

  def new
    @funds_manager = FundsManager.new
    respond_with(@funds_manager)
  end

  def edit
  end

  def create
    @funds_manager = FundsManager.new(funds_manager_params)
    @funds_manager.save
    respond_with(@funds_manager)
  end

  def import
    town = current_user.admin? ? params[:town] : current_user.town_model

    FundsManager.import(params[:file], town)
    redirect_to funds_managers_path, notice:  'Edrpou organisations imported.'

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
    @funds_manager.update(funds_manager_params)
    respond_with(@funds_manager)
  end

  def destroy
    @funds_manager.destroy
    respond_with(@funds_manager)
  end

  private

    def access_user?
      unless current_user && current_user.has_any_role?(:admin, :city_authority, :central_authority, :municipal_enterprise, :state_enterprise)
        redirect_to root_url, alert: t('export_budgets.notice_access')
      end
    end

    def set_funds_manager
      @funds_manager = FundsManager.find(params[:id])
    end

    def funds_manager_params
      params.require(:funds_manager).permit(:edrpou)
    end
end
