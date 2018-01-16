module Municipal
  class EnterprisesController < ApplicationController
    layout 'application_admin'
    before_action :access_user?

    def index
      @enterprises = current_user.admin? ? Enterprise.all : Enterprise.by_town(current_user.town_model)
    end

    def new
      files_by_user = EnterprisesFile.by_town(current_user.town_model)
      @files = current_user.admin? ? EnterprisesFile.all : files_by_user
    end

    def import
      town = get_town_by_role(params[:town])
      @file_enterprises = EnterprisesFile.new(file_enterprises_params.merge(town: town))
      @file_enterprises.owner = current_user

      respond_to do |format|
        if @file_enterprises.save
          # ImportData::MunicipalEnterprises.import(params[:file], @file_enterprises)
          format.html { redirect_to :back, notice: 'Saved.' }
        else
          format.html { redirect_to :back, notice: 'Not saved.' }
        end
      end
    end

    def destroy_file
      @file_enterprises = EnterprisesFile.find(params[:id])
      @file_enterprises.destroy

      respond_to do |format|
        format.html { redirect_to :back, notice: 'File and its enterprises have been deleted.' }
      end
    end

    def files_by_town
      @files = EnterprisesFile.by_town(params[:town])
      respond_to do |format|
        format.js
      end
    end

    private

    def get_town_by_role(town)
      current_user.admin? ? town : current_user.town_model
    end

    def access_user?
      unless current_user && current_user.has_any_role?(:admin, :city_authority, :central_authority)
        redirect_to root_url, alert: t('export_budgets.notice_access')
      end
    end

    def file_enterprises_params
      params.permit(:file, :town)
    end

  end
end
