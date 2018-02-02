module Municipal
  # common logic of municipal enterprises
  class PublicEnterprisesController < ApplicationController
    respond_to :html

    def enterprise_analysis
      @enterprises = Municipal::Enterprise.by_town(params[:town])

      respond_with(@enterprises) do |format|
        format.js { render layout: false }
        format.html { render file: 'municipal/public_enterprises/enterprise_analysis', layout: 'visify'}
      end
    end

    def search_enterprise_data
      @enterprise_files = Municipal::EnterpriseFile.where(enterprise_id: params[:enterprise_id])

      respond_to do |format|
        format.html { render 'municipal/public_enterprises/_search_enterprise_data', layout: 'visify' }
        format.json { render json: @enterprise_files }
        format.js
      end
    end

  end
end




