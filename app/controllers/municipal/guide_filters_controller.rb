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
      @type_files = Municipal::EnterpriseFile.type_files
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

    private

    def set_municipal_guide_filter
      @municipal_guide_filter = Municipal::GuideFilter.find(params[:id])
    end

    def guide_filter_params
      params.require(:municipal_guide_filter).permit(:type_file, :type_enterprise, :file)
    end
  end
end
