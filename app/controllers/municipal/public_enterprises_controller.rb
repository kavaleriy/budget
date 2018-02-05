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
      @enterprise = Municipal::Enterprise.find(params[:enterprise_id])
      @codes_form_1 = Municipal::GuideFilter.by_type(@enterprise.reporting_type, Municipal::EnterpriseFile::FORM_1).first.publish_codes
      @codes_form_2 = Municipal::GuideFilter.by_type(@enterprise.reporting_type, Municipal::EnterpriseFile::FORM_2).first.publish_codes

      respond_to do |format|
        format.html { render 'municipal/public_enterprises/_search_enterprise_data' }
        format.js
      end
    end

    def reporting_chart
      @chart = Municipal::EnterpriseFile.reporting_chart(params[:enterprise_id], params[:code])

      respond_to do |format|
        format.html { render 'municipal/public_enterprises/_reporting_chart' }
        format.json { render json: @chart }
      end
    end

  end
end




