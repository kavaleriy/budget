module Municipal
  # common logic of municipal enterprises
  class PublicEnterprisesController < Widgets::WidgetsController
    helper_method :sort_column, :sort_direction
    before_action :set_file_types, only: :file_upload_by_town
    before_action :set_enterprise, only: %i[
      search_enterprise_data
      analysis_chart_codes
      codes_by_enterprise_type
      compare_chart
    ]
    respond_to :html

    def enterprise_analysis
      @enterprises = Municipal::Enterprise.by_town(params[:town])
      render layout: 'visify'
    end

    def search_enterprise_data
      @codes_form_1 = Municipal::CodeStatus.by_type(@enterprise, Municipal::EnterpriseFile::FORM_1)
      @codes_form_2 = Municipal::CodeStatus.by_type(@enterprise, Municipal::EnterpriseFile::FORM_2)
      @codes_form_7 = Municipal::CodeStatus.by_type(@enterprise, Municipal::EnterpriseFile::OTHER)

      @municipal = @enterprise

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

    def analysis_chart
      @chart_analysis = Charts::AnalysisChart.data_chart(params[:enterprise_id], params[:codes])

      respond_to do |format|
        format.html { render 'municipal/public_enterprises/_analysis_chart' }
        format.json { render json: @chart_analysis }
      end
    end

    def analysis_chart_codes
      @codes_form_3 = Municipal::GuideFilter.by_type(@enterprise.reporting_type,
                                                     Municipal::EnterpriseFile::OTHER).first.publish_codes.map(&:code)

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
      if params[:enterprises].present?
        @enterprises = Municipal::Enterprise.where(reporting_type: @enterprise.reporting_type,
                                                   town: @enterprise.town,
                                                   :id.in => params[:enterprises])
      end

      @chart = Charts::CompareChart.data_chart(@enterprises, params[:code]) if params[:code].present?

      respond_to do |format|
        format.json { render json: @chart }
      end
    end

    def file_upload_by_town
      @municipal_enterprise_files = Municipal::EnterpriseFile.by_town(params['town_select'])          if params['town_select'].present?
      # @municipal_enterprise_files = @municipal_enterprise_files.by_enterprise(params['enterprise'])   unless params['enterprise'].blank?
      # @municipal_enterprise_files = @municipal_enterprise_files.by_file_type(params['file_type'])     unless params['file_type'].blank?
      # @municipal_enterprise_files = @municipal_enterprise_files.by_year(params['year'])               unless params['year'].blank?
      # @municipal_enterprise_files = @municipal_enterprise_files.by_file_name(params['file_name'])     unless params['file_name'].blank?

      @municipal_enterprise_files = @municipal_enterprise_files.order(sort_column + ' ' + sort_direction)
      @municipal_enterprise_files = @municipal_enterprise_files.page(params[:page]).per(25)

      respond_to do |format|
        format.html { render 'municipal/enterprise_files/index', layout: 'application' }
      end
    end

    private
    def sort_column
      Municipal::EnterpriseFile.fields.keys.include?(params[:sort]) ? params[:sort] : 'year'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
    end

    def set_file_types
      @type_files = Municipal::EnterpriseFile.type_files
    end

    def set_enterprise
      @enterprise = Municipal::Enterprise.find(params[:enterprise_id])
    end
  end
end
