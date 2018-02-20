module Municipal
  # common logic of municipal enterprises
  class PublicEnterprisesController < ApplicationController
    before_action :set_enterprise, only: [:search_enterprise_data, :analysis_chart_codes, :codes_by_enterprise_type]
    respond_to :html

    def enterprise_analysis
      @enterprises = Municipal::Enterprise.by_town(params[:town])
    end

    def search_enterprise_data
      @codes_form_1 = Municipal::GuideFilter.by_type(@enterprise.reporting_type, Municipal::EnterpriseFile::FORM_1).first.codes
      @codes_form_2 = Municipal::GuideFilter.by_type(@enterprise.reporting_type, Municipal::EnterpriseFile::FORM_2).first.codes
      @codes_form_7 = Municipal::GuideFilter.by_type(@enterprise.reporting_type, Municipal::EnterpriseFile::OTHER).first.codes

      respond_to do |format|
        format.html { render 'municipal/public_enterprises/_search_enterprise_data' }
        format.js
      end
    end

    def reporting_charts
      @charts = Charts::ReportingChart.data_charts(params[:enterprise_id], params[:codes])
      @code_type = params[:codes][0].first

      respond_to do |format|
        format.js
        format.json { render json: @charts }
      end
    end

    def analysis_chart ###
      @chart_analysis = Charts::AnalysisChart.data_chart(params[:enterprise_id], params[:codes])

      respond_to do |format|
        format.html { render 'municipal/public_enterprises/_analysis_chart' }
        format.json { render json: @chart_analysis }
      end
    end

    def analysis_chart_codes ###
      @codes_form_3 = Municipal::GuideFilter.by_type(@enterprise.reporting_type, Municipal::EnterpriseFile::OTHER).first.publish_codes.map(&:code)

      respond_to do |format|
        format.html { render 'municipal/public_enterprises/_analysis_chart' }
        format.json { render json: @codes_form_3 }
      end
    end

    def analysis_charts
      @charts = Charts::AnalysisChart.data_chart(params[:enterprise_id], params[:codes])
      @code_type = params[:codes][0].first

      respond_to do |format|
        format.js { render 'municipal/public_enterprises/reporting_charts' }
        format.json { render json: @charts }
      end
    end

    def codes_by_enterprise_type
      @codes_form = Municipal::GuideFilter.by_type(@enterprise.reporting_type, params[:code_type]).first.codes

      respond_to do |format|
        format.js
      end
    end

    def compare_chart
      # binding.pry
      # @codes_form = Municipal::GuideFilter.by_type(@enterprise.reporting_type, params[:code_type]).first.codes
      #
      # respond_to do |format|
      #   format.js
      # end
    end

    private

    def set_enterprise
      @enterprise = Municipal::Enterprise.find(params[:enterprise_id])
    end
  end
end




