module Municipal
  # upload enterprises files and parse them
  class EnterpriseFilesController < MunicipalController
    before_action :set_municipal_enterprise_file, only: [:show, :edit, :update, :destroy, :show_code_values]
    before_action :set_enterprises, only: [:new, :edit]

    respond_to :html

    def index
      @municipal_enterprise_files = current_user.admin? ? Municipal::EnterpriseFile.all : Municipal::EnterpriseFile.by_town(current_user.town_model)
      @municipal_enterprise_files = @municipal_enterprise_files.by_town(params['town_select'])   if params['town_select'].present?

      respond_to do |format|
        format.js
        format.html
      end
    end

    # def show
    #   respond_with(@municipal_enterprise_file)
    # end

    def show_code_values
      @code_values = Municipal::CodeValue.by_file(@municipal_enterprise_file)
    end

    def new
      @municipal_enterprise_file = Municipal::EnterpriseFile.new
      respond_with(@municipal_enterprise_file)
    end

    # def edit; end

    def create
      @municipal_enterprise_file = Municipal::EnterpriseFile.new(enterprise_file_params)
      @municipal_enterprise_file.owner = current_user

      respond_to do |format|
        if @municipal_enterprise_file.save
          unless enterprise_file_params[:file_type].eql?(Municipal::EnterpriseFile::OTHER)
            ImportData::ParseReport.import_form(enterprise_file_params[:file], @municipal_enterprise_file)
          end
          format.html { redirect_to municipal_enterprise_files_url, notice: 'Файл успішно додано.' }
        else
          format.html { render action: 'new' }
          format.json { render json: @municipal_enterprise_file.errors, status: :unprocessable_entity }
        end
      end
      # respond_with(@municipal_enterprise_file)
    end

    # def update
    #   @municipal_enterprise_file.remove_file! if enterprise_file_params[:file].present?
    #   @municipal_enterprise_file.update(enterprise_file_params)
    #   respond_with(@municipal_enterprise_file)
    # end

    def destroy
      respond_to do |format|
        if access_by_town?(@municipal_enterprise_file) || current_user.admin?
          @municipal_enterprise_file.destroy
          notice =  'Файл видалено.'
        else
          notice =  'У вас немає прав для видалення цього файлу.'
        end
        format.html { redirect_to municipal_enterprise_files_path, notice: notice }
      end
    end

    private

    def access_by_town?(file)
      current_user.town.eql?(file.enterprise.town)
    end

    def set_enterprises
      @enterprises = Municipal::Enterprise.by_town(current_user.town_model)
      @type_files = Municipal::EnterpriseFile.type_files
    end

    def set_municipal_enterprise_file
      @municipal_enterprise_file = Municipal::EnterpriseFile.find(params[:id])
    end

    def enterprise_file_params
      params.require(:municipal_enterprise_file).permit(:enterprise, :file_type, :year, :file)
    end

  end
end
