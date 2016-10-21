class ExternalApiController < ApplicationController
  layout 'visify'
  require 'external_api'

  # TODO: extract lib

  # http://localhost:3000/external_api/edata?payer_edrpous=39883094&recipt_edrpous=09334702&format=json

  def edata
    def get_params
      data = {
          'startdate' => '01-05-2016',
          # 'enddate' => '30-10-2015',
      }

      # data['payer_edrpous'] = [params[:payer_edrpous]]
      # data['recipt_edrpous'] = [params[:recipt_edrpous]]

      data['payer_edrpous'] = ['39883094']
      data['recipt_edrpous'] = ['09334702']

      data.delete_if { |key, value| value.blank? }
    end

    def get_payments data
      uri = URI.parse('http://api.e-data.gov.ua:8080/api/rest/1.0/transactions')
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
      request.body = data.to_json

      JSON.parse(http.request(request).body)['response']['transactions'] rescue {}
    end

    data = get_params
    @payments = (get_payments data).take(20)

    respond_to do |format|
      format.html
      format.json { render json: @payments }
    end
  end

  def prozzoro_info
    require 'external_api'
    @prozzoro_info = ExternalApi.prozzoro_data(params[:prozzoro_id])
    respond_to do |format|
      format.js {
        render file: 'external_api/api_info',
               locals: {
                   selector: '#prozzoro',
                   partial_name: 'external_api/prozzoro_info'
               }
      }
    end
  end

  def e_data
    e_data_payments = ExternalApi.e_data_payments(params[:edrpou_artist], params[:edrpou_spending_units]) || []

    @payments = Kaminari.paginate_array(e_data_payments).page(params[:page]).per(10)

    respond_to do |format|
      format.html {render partial: 'modules/classifier/search_e_data',layout: false}
      format.js {
        render file: 'external_api/api_info',
               locals: {
                   selector: '#e-data',
                   partial_name: 'modules/classifier/search_e_data'
               }
      }
    end
  end
  def edr_info
    @edr_data = ExternalApi.edr_data(params[:edrpou]).first

    respond_to do |format|
      format.js {
        render file: 'external_api/api_info',
               locals: {
                   selector: '#edr',
                   partial_name: 'external_api/edr_info'
               }
      }
    end
  end
end
