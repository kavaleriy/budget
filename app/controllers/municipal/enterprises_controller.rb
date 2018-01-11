module Municipal
  class EnterprisesController < ApplicationController
    layout 'application_admin'
    before_action :access_user?

    def index
      @enterprises = current_user.admin? ? Enterprise.all : Enterprise.by_town(current_user.town_model)
    end

    def new
      @files = current_user.admin? ? EnterprisesFile.all : EnterprisesFile.by_town(current_user.town_model)
    end

    def import
      @file_enterprises = EnterprisesFile.new(file_enterprises_params)
      @file_enterprises.owner = current_user

      town = get_town_by_role(params[:town])
      Enterprise.import(params[:file], town)

      respond_to do |format|
        if @file_enterprises.save
          format.html { redirect_to :back, notice: 'Saved.' }
        else
          format.html { redirect_to :back, notice: 'Not saved.' }
        end
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
