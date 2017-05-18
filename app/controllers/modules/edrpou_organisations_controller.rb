class Modules::EdrpouOrganisationsController < ApplicationController
  layout 'application_admin'
  before_action :access_user?
  before_action :set_modules_edrpou_organisation, only: [:show, :edit, :update, :destroy]
  # skip_before_action :check_admin_permission

  respond_to :html

  def index
    @modules_edrpou_organisations = Modules::EdrpouOrganisation.all
    respond_with(@modules_edrpou_organisations)
  end

  def show
    respond_with(@modules_edrpou_organisation)
  end

  def new
    @modules_edrpou_organisation = Modules::EdrpouOrganisation.new
    respond_with(@modules_edrpou_organisation)
  end

  def edit
  end

  def create
    @modules_edrpou_organisation = Modules::EdrpouOrganisation.new(edrpou_organisation_params)
    @modules_edrpou_organisation.save
    respond_with(@modules_edrpou_organisation)
  end

  def update
    @modules_edrpou_organisation.update(edrpou_organisation_params)
    respond_with(@modules_edrpou_organisation)
  end

  def destroy
    @modules_edrpou_organisation.destroy
    respond_with(@modules_edrpou_organisation)
  end

  private

    def access_user?
      unless current_user && current_user.has_any_role?(:admin, :city_authority, :central_authority, :municipal_enterprise, :state_enterprise)
        redirect_to root_url, alert: t('export_budgets.notice_access')
      end
    end

    def set_modules_edrpou_organisation
      @modules_edrpou_organisation = Modules::EdrpouOrganisation.find(params[:id])
    end

    def edrpou_organisation_params
      params.require(:modules_edrpou_organisation).permit(:edrpou)
    end
end
