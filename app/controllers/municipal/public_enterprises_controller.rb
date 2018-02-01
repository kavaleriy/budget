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
  end
end




