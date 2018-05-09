module Municipal
  # upload enterprises files and parse them
  class EnterpriseFilesController < MunicipalController
    helper_method :sort_column, :sort_direction
    before_action :set_municipal_enterprise_file, only: [:show, :edit, :update, :destroy, :show_code_values]
    before_action :set_enterprises, only: [:new, :edit]

    respond_to :html

    def index
      @municipal_enterprise_files = current_user.admin? ? Municipal::EnterpriseFile.all : Municipal::EnterpriseFile.by_town(current_user.town_model)
      # @municipal_enterprise_files = @municipal_enterprise_files.by_town(params['town_select'])   if params['town_select'].present?

      @municipal_enterprise_files = @municipal_enterprise_files.order(sort_column + ' ' + sort_direction)
      @municipal_enterprise_files = @municipal_enterprise_files.page(params[:page])

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

    def select_enterprises_by_town
      enterprises_by_town(params[:town_id])

      respond_to do |format|
        format.js
      end
    end

    # def edit; end

    def create
      @municipal_enterprise_file = Municipal::EnterpriseFile.new(enterprise_file_params)
      @municipal_enterprise_file.owner = current_user

      # set_status
      respond_to do |format|
        if @municipal_enterprise_file.save
          unless enterprise_file_params[:file_type].eql?(Municipal::EnterpriseFile::OTHER)
            ImportData::ParseReport.import_form(enterprise_file_params[:file], @municipal_enterprise_file)
            # set_status
          end
          format.html { redirect_to municipal_enterprise_files_url, notice: 'Файл успішно додано.' }
        else
          format.html { render action: 'new' }
          format.json { render json: @municipal_enterprise_file.errors, status: :unprocessable_entity }
        end
      end
      # respond_with(@municipal_enterprise_file)
    end

    def set_status
      ent_files_by_type = Municipal::EnterpriseFile.where(enterprise: @municipal_enterprise_file.enterprise, file_type: @municipal_enterprise_file.file_type).order(year: :desc)
      # binding.pry

      return unless ent_files_by_type.size >= 2

      if @municipal_enterprise_file.year >= ent_files_by_type.second.try(:year)
        # set form 1, form 2 chart status
        # set analysis chart
        p "#########  set form 1, form 2 chart status"
        codes = {}
        ent_files_by_type.first.code_values.each do |code|
          codes[code.code] = []
          codes[code.code].push(code.value)
          p "code - #{code.code}, value - #{code.value}"
        end
        ent_files_by_type.second.code_values.each do |code|
          codes[code.code] = [] unless codes.key?(code.code)
          codes[code.code].try(:push, code.value)
          p "code - #{code.code}, value - #{code.value}"
        end

        codes.each do |code|
          status = Municipal::CodeStatus.new(enterprise: @municipal_enterprise_file.enterprise, code: code[0])
          values = code[1]

          next if values[0].blank? && values[1].blank?

          status_type =
            if values[0].to_i > values[1].to_i
              p "#{code[0]} - up!"
              :up
            elsif values[0].to_i == values[1].to_i
              p "#{code[0]} - some!"
              :some
            elsif values[0].to_i < values[1].to_i
              p "#{code[0]} - down!"
              :down
            end

          status.status = status_type
          p "#{code[0]} code 0 - #{values[0]}, code 1 - #{values[1]}"
          p status
        end
        binding.pry
      end

      if @municipal_enterprise_file.year >= ent_files_by_type.third.try(:year)
        # set analysis chart status
        p "#########  set analysis chart status"
      end

    end

    # def update
    #   @municipal_enterprise_file.remove_file! if enterprise_file_params[:file].present?
    #   @municipal_enterprise_file.update(enterprise_file_params)
    #   respond_with(@municipal_enterprise_file)
    # end

    def destroy
      respond_to do |format|
        if current_user.admin? || access_by_town?(@municipal_enterprise_file)
          @municipal_enterprise_file.destroy
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
