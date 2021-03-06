module Municipal
  # upload guide filters file and parse their code_descriptions
  class GuideFiltersController < MunicipalController
    before_action :set_municipal_guide_filter, only: [:show, :edit, :update, :destroy]

    respond_to :html

    def index
      @municipal_guide_filters = Municipal::GuideFilter.all
      respond_with(@municipal_guide_filters)
    end

    def show
      respond_with(@municipal_guide_filter)
    end

    def new
      @municipal_guide_filter = Municipal::GuideFilter.new
      set_data_select
      respond_with(@municipal_guide_filter)
    end

    def edit; end

    def create
      @municipal_guide_filter = Municipal::GuideFilter.new(guide_filter_params)

      respond_to do |format|
        if @municipal_guide_filter.save
          ImportData::ParseGuideFilter.import(guide_filter_params[:file], @municipal_guide_filter)
          format.html { redirect_to municipal_guide_filters_url, notice: 'Файл успішно додано.' }
        else
          set_data_select
          format.html { render action: 'new' }
          format.json { render json: @municipal_guide_filter.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      @municipal_guide_filter.update(guide_filter_params)
      respond_with(@municipal_guide_filter)
    end

    def destroy
      @municipal_guide_filter.destroy
      respond_with(@municipal_guide_filter)
    end

    def update_code_info
      @code_info = Municipal::CodeDescription.find(params[:id])
      respond_to do |format|
        if @code_info.update(code_info_params)
          msg = { class_name: 'success', message: I18n.t('repairing.layers.update.success') }
        else
          msg = { class_name: 'danger', message: I18n.t('repairing.layers.update.error') }
        end
        format.js
        format.json { render json: msg }
      end
    end

    private

    def access_user?
      unless current_user && current_user.admin?
        redirect_to root_url, alert: t('export_budgets.notice_access')
      end
    end

    def set_municipal_guide_filter
      @municipal_guide_filter = Municipal::GuideFilter.find(params[:id])
    end

    def set_data_select
      @report_type = Municipal::Enterprise.report_type
      @type_codes = Municipal::EnterpriseFile.type_codes
    end

    def guide_filter_params
      params.require(:municipal_guide_filter).permit(:type_file, :type_enterprise, :file)
    end

    def code_info_params
      params.permit(:publish, :description, :unit, :title)
    end
  end
end
