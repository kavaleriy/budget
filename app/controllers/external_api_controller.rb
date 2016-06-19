class ExternalApiController < ApplicationController
  layout 'visify'

  # TODO: extract lib

  # http://localhost:3000/external_api/edata?payer_edrpous=39883094&recipt_edrpous=09334702&format=json
  
  def edata
    def get_params
      data = {
          'startdate' => '01-01-2016',
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

end
