module Municipal
  class EnterprisesController < AdminController

    def file_enterprises; end

    def import
      @file_enterprises = EnterprisesFile.new(file_enterprises_params)
      @file_enterprises.owner = current_user

      respond_to do |format|
        if @file_enterprises.save
          format.html { redirect_to :back, notice: 'Saved.' }
        else
          format.html { redirect_to :back, notice: 'Not saved.' }
        end
      end
    end


    private

    def file_enterprises_params
      params.permit(:file, :town)
    end

  end
end
