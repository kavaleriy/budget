module Municipal
  # upload enterprises from file and show their list
  class EnterprisesController < MunicipalController
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
          ImportData::MunicipalEnterprises.import(params[:file], @file_enterprises)
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

    def file_enterprises_params
      params.permit(:file, :town)
    end

  end
end
