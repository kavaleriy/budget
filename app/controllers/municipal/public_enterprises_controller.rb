module Municipal
  # common logic of municipal enterprises
  class PublicEnterprisesController < ApplicationController
    respond_to :html

    def enterprise_analysis
      @enterprises = Municipal::Enterprise.by_town(params[:town])
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

    def analysis_chart
      # @chart = Municipal::EnterpriseFile.reporting_chart(params[:enterprise_id], params[:code])
      @chart_analysis = Municipal::EnterpriseFile.analysis_chart(params[:enterprise_id], params[:code_an])

      respond_to do |format|
        format.html { render 'municipal/public_enterprises/_analysis_chart' }
        format.json { render json: @chart_analysis }
        # format.json { render json: @chart }
      end
    end

  end
end




