# frozen_string_literal: true

module Municipal
  # upload enterprises files and parse them
  class EnterpriseFilesController < MunicipalController
    helper_method :sort_column, :sort_direction
    before_action :set_municipal_enterprise_file, only: [:show, :edit, :update, :destroy, :show_code_values]
    before_action :set_enterprises, only: [:new, :edit, :create]
    before_action :set_file_types, only: [:index, :new, :edit, :create]

    respond_to :html

    def index
      @municipal_enterprise_files = current_user.region_admin? ? Municipal::EnterpriseFile.all : Municipal::EnterpriseFile.by_town(current_user.town_model)
      @municipal_enterprise_files = @municipal_enterprise_files.by_town(params['town_select'])       if params['town_select'].present?
      @municipal_enterprise_files = @municipal_enterprise_files.by_enterprise(params['enterprise'])  unless params['enterprise'].blank?
      @municipal_enterprise_files = @municipal_enterprise_files.by_file_type(params['file_type'])    unless params['file_type'].blank?
      @municipal_enterprise_files = @municipal_enterprise_files.by_year(params['year'])              unless params['year'].blank?
      @municipal_enterprise_files = @municipal_enterprise_files.by_file_name(params['file_name'])    unless params['file_name'].blank?

      @municipal_enterprise_files = @municipal_enterprise_files.order(sort_column + ' ' + sort_direction)
      @municipal_enterprise_files = @municipal_enterprise_files.page(params[:page]).per(25)

      respond_to do |format|
        format.js
        format.html
      end
    end

    # def show
    #   respond_with(@municipal_enterprise_file)
    # end

    def show_code_values
      set_code_values
    end

    def new
      @municipal_enterprise_file = Municipal::EnterpriseFile.new
      respond_with(@municipal_enterprise_file)
    end

    def select_enterprises_by_town
      enterprises_by_town(params[:town_id])

      respond_to do |format|
        format.js
      end
    end

    # def edit; end

    def create
      unless enterprise_file_params.blank?
        @municipal_enterprise_file = Municipal::EnterpriseFile.where(enterprise: enterprise_file_params[:enterprise]).find_by(year: enterprise_file_params[:year])
        @municipal_enterprise_file.destroy
      end

      @municipal_enterprise_file = Municipal::EnterpriseFile.new(enterprise_file_params)
      @municipal_enterprise_file.owner = current_user

      respond_to do |format|
        if @municipal_enterprise_file.save
          unless enterprise_file_params[:file_type].eql?(Municipal::EnterpriseFile::OTHER)
            ImportData::ParseReport.import_form(enterprise_file_params[:file], @municipal_enterprise_file)
            StatusCode::SetStatus.generate_statuses(@municipal_enterprise_file)
          end
          set_code_values
          format.html { render action: 'show_code_values', notice: 'Файл успішно додано.' }
        else
          format.html { render action: 'new' }
          format.json { render json: @municipal_enterprise_file.errors, status: :unprocessable_entity }
        end
      end
    end

    # def update
    #   @municipal_enterprise_file.remove_file! if enterprise_file_params[:file].present?
    #   @municipal_enterprise_file.update(enterprise_file_params)
    #   respond_with(@municipal_enterprise_file)
    # end

    def destroy
      respond_to do |format|
        if current_user.region_admin? || access_by_town?(@municipal_enterprise_file)
          @municipal_enterprise_file.destroy
          StatusCode::SetStatus.del_statuses(@municipal_enterprise_file)
          notice =  'Файл видалено.'
        else
          notice =  'У вас немає прав для видалення цього файлу.'
        end
        format.html { redirect_to municipal_enterprise_files_path, notice: notice }
      end
    end

    private

    def sort_column
      Municipal::EnterpriseFile.fields.keys.include?(params[:sort]) ? params[:sort] : 'year'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
    end

    def access_by_town?(file)
      current_user.town_model.eql?(file.enterprise.town)
    end

    def set_enterprises
      enterprises_by_town(current_user.town_model)
    end

    def set_code_values
      @code_values = Municipal::CodeValue.by_file(@municipal_enterprise_file)
    end

    def set_file_types
      @type_files = Municipal::EnterpriseFile.type_files
    end

    def enterprises_by_town(town)
      @enterprises = Municipal::Enterprise.by_town(town)
    end

    def set_municipal_enterprise_file
      @municipal_enterprise_file = Municipal::EnterpriseFile.find(params[:id])
    end

    def enterprise_file_params
      params.require(:municipal_enterprise_file).permit(:enterprise, :file_type, :year, :file)
    end
  end
end
