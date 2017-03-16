class ExternalApiController < ApplicationController
  layout 'visify'
  require 'external_api'
  before_action :set_repair, only: [:e_data, :edr, :prozzoro]
  # http://localhost:3000/external_api/edata?payer_edrpous=39883094&recipt_edrpous=09334702&format=json

  # def edata
  #   def get_params
  #     data = {
  #         'startdate' => '01-05-2016',
  #         # 'enddate' => '30-10-2015',
  #     }
  #
  #     # data['payer_edrpous'] = [params[:payer_edrpous]]
  #     # data['recipt_edrpous'] = [params[:recipt_edrpous]]
  #
  #     data['payer_edrpous'] = ['39883094']
  #     data['recipt_edrpous'] = ['09334702']
  #
  #     data.delete_if { |key, value| value.blank? }
  #   end
  #
  #   def get_payments data
  #     uri = URI.parse('http://api.e-data.gov.ua:8080/api/rest/1.0/transactions')
  #     http = Net::HTTP.new(uri.host, uri.port)
  #
  #     request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
  #     request.body = data.to_json
  #
  #     JSON.parse(http.request(request).body)['response']['transactions'] rescue {}
  #   end
  #
  #   data = get_params
  #   @payments = (get_payments data).take(20)
  #
  #   respond_to do |format|
  #     format.html
  #     format.json { render json: @payments }
  #   end
  # end

  def prozzoro

    @prozzoro_info = ExternalApi.prozzoro_data(@repairing_repairs.prozzoro_id)
    @prozzoro_info['docs'] = @prozzoro_info['documents']
    @prozzoro_info['docs'] += @prozzoro_info['contracts'].first['documents'] || [] unless @prozzoro_info['contracts'].blank?

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
    @repairing_repairs.edrpou_spending_units = ''
    @repairing_repairs.edrpou_artist = 33147770
    e_data_payments = ExternalApi.e_data_payments(@repairing_repairs.edrpou_spending_units, @repairing_repairs.edrpou_artist)

    respond_to do |format|
      if e_data_payments.blank?
        format.html{ render partial: 'no_data_yet' }
        format.js {
          render file: 'external_api/api_info',
                 locals: {
                     selector: '#e-data #edata_payments tbody',
                     partial_name: 'no_data_yet'
                 }
        }
      else
        @payments = Kaminari.paginate_array(e_data_payments).page(params[:page]).per(10)
        format.html {render partial: 'modules/classifier/search_e_data',layout: false}
        format.js {
          render file: 'external_api/e_data',
                 locals: {
                     selector: '#e-data',
                     partial_name: 'modules/classifier/search_e_data'
                 }
        }
      end

    end
  end
  def edr
    edr_data_arr = ExternalApi.edr_data(@repairing_repairs.edrpou_artist)
    @edr_data = edr_data_arr.first unless edr_data_arr.nil?

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

  def no_data_yet
    respond_to do |format|
      format.js {
        render file: 'external_api/api_info',
               locals: {
                   selector: params[:selector],
                   partial_name: 'external_api/no_data_yet',
               }
      }
    end
  end
  private
  def set_repair
    @repairing_repairs = Repairing::Repair.find(params[:repair_id])
  end
end
