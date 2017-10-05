class ExternalApiController < ApplicationController
  layout 'visify'
  require 'external_api'
  before_action :set_repair, only: [:e_data, :edr, :prozzoro]

  def prozzoro
    @prozzoro_info = ExternalApi.prozzoro_data(@repairing_repairs.prozzoro_id)
    unless @prozzoro_info.blank?
      @prozzoro_info['docs'] = @prozzoro_info['documents']
      @prozzoro_info['docs'] += @prozzoro_info['contracts'].first['documents'] || [] unless @prozzoro_info['contracts'].blank?
    end

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
    # data_bot = ExternalApi.data_bot(@repairing_repairs.edrpou_spending_units, @repairing_repairs.edrpou_artist)

    e_data_payments = ExternalApi.e_data_payments(@repairing_repairs.edrpou_spending_units, @repairing_repairs.edrpou_artist)

    respond_to do |format|
      if e_data_payments.blank?
        format.html{ render partial: 'no_data_yet' }
        format.js {
          render file: 'external_api/api_info',
                 locals: {
                     selector: '#e-data',
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
