class ExternalApiController < ApplicationController
  layout 'visify'
  require 'external_api'
  before_action :set_repair, only: [:e_data, :edr, :prozzoro, :judicial_register]

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
    e_data_payments =
      if @repairing_repairs.edrpou_spending_units.blank? || @repairing_repairs.edrpou_artist.blank?
        ''
      else
        # return array data, empty array or hash with errors
        ExternalApi.e_data_payments(@repairing_repairs.edrpou_spending_units, @repairing_repairs.edrpou_artist)
      end

    respond_to do |format|
      if e_data_payments.blank? || e_data_payments.is_a?(Hash)
        # if e_data_payments empty or hash with errors
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

  def judicial_register
    respond_to do |format|
      lack_data(format) if @repairing_repairs.edrpou_artist.blank?

      # return hash with company data or hash error
      company_data = ExternalApi.data_bot_decisions(@repairing_repairs.edrpou_artist)

      if company_has_decisions?(company_data)
        @judicial_decisions = Kaminari.paginate_array(company_data['warnings'][0]['decisions']).page(params[:page]).per(10)
        format.html { render partial: 'external_api/judicial_register/judicial_register_table', layout: false }
        format.js do
          render file: 'external_api/judicial_register/judicial_register',
                 locals: {
                   selector: '#judicial-register',
                   partial_name: 'external_api/judicial_register/judicial_register_table'
                 }
        end
      else
        message = t('external_api.judicial_register.no_data_message')
        lack_data(format, message)
      end
    end
  end

  def no_data_yet
    respond_to do |format|
      format.js do
        render file: 'external_api/api_info',
               locals: {
                 selector: params[:selector],
                 partial_name: 'external_api/no_data_yet'
               }
      end
    end
  end

  private

  def set_repair
    @repairing_repairs = Repairing::Repair.find(params[:repair_id])
  end

  def lack_data(format, message = nil)
    format.html { render partial: 'external_api/no_data_yet' }
    format.js do
      render file: 'external_api/api_info',
             locals: {
               selector: '#judicial-register',
               partial_name: 'no_data_yet',
               message: message
             }
    end
  end

  def company_has_decisions?(company_data)
    company_data.key?('warnings') && company_data['warnings'][0].key?('decisions')
  end

end
