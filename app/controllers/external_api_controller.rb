class ExternalApiController < ApplicationController
  layout 'visify'
  require 'external_api'
  before_action :set_repair, only: [:e_data, :edr, :prozzoro, :judicial_register]

  def prozzoro
    prozzoro_id = inner_id(@repairing_repairs.prozzoro_id)
    @prozzoro_info = ExternalApi.prozzoro_data(prozzoro_id)

    if @prozzoro_info.present?
      @prozzoro_info['docs'] = []
      @prozzoro_info['docs'] = @prozzoro_info['documents'] if @prozzoro_info['documents']
      @prozzoro_info['docs'] += @prozzoro_info['contracts'].first['documents'] || [] if @prozzoro_info['contracts'].present?
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
    respond_to do |format|
      selector = '#edr'
      edrpou = @repairing_repairs.edrpou_artist

      @edr_data_bot = ExternalApi.data_bot_edr(edrpou).first if edrpou.present?
      if @edr_data_bot && @edr_data_bot.try(:key?, 'full_name')
        format.js {
          render file: 'external_api/api_info',
                 locals: {
                   selector: selector,
                   partial_name: 'external_api/edr_info'
                 }
        }
      else
        lack_data(format, selector)
      end
    end
  end

  def judicial_register
    respond_to do |format|
      selector = '#judicial-register'
      lack_data(format, selector) if @repairing_repairs.edrpou_artist.blank?

      company_data = ExternalApi.data_bot_decisions(@repairing_repairs.edrpou_artist)
      unless company_data['items'].blank?
        @judicial_decisions = Kaminari.paginate_array(company_data['items']).page(params[:page]).per(10)
        format.html { render partial: 'external_api/judicial_register/judicial_register_table', layout: false }
        format.js do
          render file: 'external_api/judicial_register/judicial_register',
                 locals: {
                   selector: selector,
                   partial_name: 'external_api/judicial_register/judicial_register_table'
                 }
        end
      else
        message = t('external_api.judicial_register.no_data_message')
        lack_data(format, selector, message)
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

  def lack_data(format, selector, message = nil)
    format.html { render partial: 'external_api/no_data_yet' }
    format.js do
      render file: 'external_api/api_info',
             locals: {
               selector: selector,
               partial_name: 'no_data_yet',
               message: message
             }
    end
  end

  def inner_id(id)
    # parse prozorro.gov.ua for get inner_id
    # example UA-2016-10-12-000021-b
    # mast be 5f76dc96079549f789c817e04b8bee2c
    if id.try(:start_with?, 'UA')
      doc = Nokogiri::HTML(RestClient.get("https://prozorro.gov.ua/tender/#{id}"))
      doc.css('.tender--head--inf').first.children.last.to_s.squish
    else
      id
    end
  end

end
