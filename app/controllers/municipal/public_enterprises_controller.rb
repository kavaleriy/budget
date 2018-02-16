module Municipal
  # common logic of municipal enterprises
  class PublicEnterprisesController < ApplicationController
    before_action :set_enterprise, only: [:search_enterprise_data, :analysis_chart_codes]
    respond_to :html

    def enterprise_analysis
      @enterprises = Municipal::Enterprise.by_town(params[:town])
    end

    def search_enterprise_data
      @codes_form_1 = Municipal::GuideFilter.by_type(@enterprise.reporting_type, Municipal::EnterpriseFile::FORM_1).first.publish_codes
      @codes_form_2 = Municipal::GuideFilter.by_type(@enterprise.reporting_type, Municipal::EnterpriseFile::FORM_2).first.publish_codes

      respond_to do |format|
        format.html { render 'municipal/public_enterprises/_search_enterprise_data' }
        format.js
      end
    end

    def reporting_chart
      @chart = Charts::ReportingChart.data_chart(params[:enterprise_id], params[:code])

      respond_to do |format|
        format.html { render 'municipal/public_enterprises/_reporting_chart' }
        format.json { render json: @chart }
      end
    end

    def reporting_charts
      @charts = Charts::ReportingChart.data_charts(params[:enterprise_id], params[:codes])

      respond_to do |format|
        format.js
        format.json { render json: @charts }
      end
    end

    def analysis_chart
      @chart_analysis = Charts::AnalysisChart.data_chart(params[:enterprise_id], params[:codes])

      respond_to do |format|
        format.html { render 'municipal/public_enterprises/_analysis_chart' }
        format.json { render json: @chart_analysis }
      end
    end

    def analysis_chart_codes
      @codes_form_3 = Municipal::GuideFilter.by_type(@enterprise.reporting_type, Municipal::EnterpriseFile::OTHER).first.publish_codes.map(&:code)

      respond_to do |format|
        format.html { render 'municipal/public_enterprises/_analysis_chart' }
        format.json { render json: @codes_form_3 }
      end
    end

    private

    def set_enterprise
      @enterprise = Municipal::Enterprise.find(params[:enterprise_id])
    end
  end
end




