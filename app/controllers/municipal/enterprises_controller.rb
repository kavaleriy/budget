module Municipal
  # upload enterprises from file and show their list
  class EnterprisesController < MunicipalController
    before_action :access_admin?, only: [:check_debt, :check_score]
    before_action :set_enterprise, only: [:edit, :update, :destroy, :check_debt, :check_score]

    def index
      @enterprises = current_user.region_admin? ? Enterprise.all : Enterprise.by_town(current_user.town_model)
    end

    def new
      @files = current_user.region_admin? ? EnterprisesList.all : EnterprisesList.by_town(current_user.town_model)
    end

    def import
      town = get_town_by_role(params[:town])
      @file_enterprises = EnterprisesList.new(file_enterprises_params.merge(town: town))
      @file_enterprises.owner = current_user

      respond_to do |format|
        if @file_enterprises.save
          ImportData::MunicipalEnterprises.import(params[:file], @file_enterprises)
          format.html { redirect_to :back, notice: 'Файл збережено.' }
        else
          format.html { redirect_to :back, notice: 'Не збережено.' }
        end
      end
    end

    def destroy_file
      @file_enterprises = EnterprisesList.find(params[:id])
      @file_enterprises.destroy

      respond_to do |format|
        format.html { redirect_to :back, notice: 'Файл видалено.' }
      end
    end

    def edit
      @report_type = Municipal::Enterprise.report_type
    end

    def update
      respond_to do |format|
        if @enterprise.update(enterprise_params)
          format.html { redirect_to municipal_enterprises_path, notice: 'Успішно оновлено.' }
        else
          format.html { render :edit }
          format.json { render json: @enterprise.errors, status: :unprocessable_entity }
        end
      end
    end

    def check_debt
      respond_to do |format|
        YouScoreApi.set_tax_debt(@enterprise)
        format.html { redirect_to :back, notice: 'Податковий борг перевірено.' }
      end
    end

    def check_score
      respond_to do |format|
        YouScoreApi.set_financial_scoring(@enterprise)
        format.html { redirect_to :back, notice: 'Показники перевірено.' }
      end
    end

    def destroy
      respond_to do |format|
        if current_user.region_admin? || access_by_town?(@enterprise)
          @enterprise.destroy
          notice =  'Видалено.'
        else
          notice =  'У вас немає прав для видалення.'
        end
        format.html { redirect_to municipal_enterprises_path, notice: notice }
      end
    end

    def files_by_town
      @files = EnterprisesList.by_town(params[:town])
      respond_to do |format|
        format.js
      end
    end

    private

    def access_admin?
      unless current_user && current_user.admin?
        redirect_to root_url, alert: t('export_budgets.notice_access')
      end
    end

    def access_by_town?(enterprise)
      current_user.town.eql?(enterprise.town)
    end

    def set_enterprise
      @enterprise = Municipal::Enterprise.find(params[:id])
    end

    def get_town_by_role(town)
      current_user.region_admin? ? town : current_user.town_model
    end

    def file_enterprises_params
      params.permit(:file, :town)
    end

    def enterprise_params
      params.require(:municipal_enterprise).permit(:edrpou, :title, :reporting_type)
    end

  end
end
