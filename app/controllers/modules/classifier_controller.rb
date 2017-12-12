include BudgetFileUpload
module Modules
  class ClassifierController < ApplicationController
    before_action :town, only: [:search_data, :advanced_search, :by_type, :by_edrpou]

    after_filter :allow_iframe, only: [:search_data, :by_edrpou]

    def search_data
      items = FundsManager.by_town(params[:town_id])
      if items.any?
        @items = items
      else
        @items = items_by_koatuu.only(:pnaz, :edrpou)
      end

      respond_to do |format|
        format.html { render file: 'modules/classifier/search_data', layout: 'visify'}
        format.js
      end
    end

    def by_edrpou
      @classifier = Classifier.find_by(edrpou: params[:payers_edrpous])
      respond_to do |format|
        format.html { render layout: 'visify'}
        format.js
      end
    end


    def direct_link
      # access from direct link (socials networks)
      @items = items_by_koatuu.only(:pnaz, :edrpou)
      @types_payer = Modules::ClassifierType.where(payer: true).all
      @types_receipt = Modules::ClassifierType.where(receipt: true).all
      payer = @items.where(edrpou: params[:payers_edrpous]).first if params[:payers_edrpous].present?
      recipt = @items.where(edrpou: params[:recipt_edrpous]).first if params[:recipt_edrpous].present?
      respond_to do |format|
        if params[:period].blank?
          format.html { render 'modules/classifier/share_search' }
        else
          format.html { render 'modules/classifier/share_adv_search', locals: { payer: payer ||= '', recipt: recipt ||= '' } }
        end
      end
    end

    def search_e_data
      require 'xls_worker'
      data = sort_e_data
      if params[:by_purpose]
        query_str = params[:by_purpose].mb_chars.downcase.to_s
        data.select! do |transaction|
          purpose_title = transaction['payment_details'].mb_chars.downcase.to_s
          purpose_title.include?(query_str)
        end
      end
      @payments = Kaminari.paginate_array(data).page(params[:page]).per(10) unless data.blank?

      # this variable are using for chart
      @receivers = ExternalApi::most_received(params[:payers_edrpous], params[:recipt_edrpous], (start_date(params[:period]) unless params[:period].blank?), (end_date(params[:period]) unless params[:period].blank?)).first(10)

      respond_to do |format|
        # TODO should be rewrite using as :template
        format.html {render 'modules/classifier/_search_e_data', layout: 'visify'}
        format.json { render json: @payments }
        # format.csv { send_data Modules::Classifier.to_csv(data) }
        format.xls { send_data XlsWorker.create_xls_with_e_data(data) }
        # switch between '*.js.erb' depend on sorting params
        if params[:sort_col].blank?
          format.js { render 'modules/classifier/search_e_data' }
        else
          format.js { render 'modules/classifier/sort_e_data' }
        end
      end
    end

    def search_data_bot
      data = sort_data_bot
      @judicial_decisions = Kaminari.paginate_array(data).page(params[:page]).per(10) unless data.blank?

      respond_to do |format|
        format.json { render json: @judicial_decisions }
        unless params[:sort_col].blank?
          format.js { render 'external_api/judicial_register/sort_data_bot' }
        end
      end
    end

    def advanced_search
      @types_payer = Modules::ClassifierType.where(payer: true).all
      @types_receipt = Modules::ClassifierType.where(receipt: true).all
      respond_to do |format|
        format.html { render file: 'modules/classifier/advanced_search', layout: 'visify'}
        format.js
      end
    end

    def select_collection
      @items = Modules::Classifier.search_part_title(params[:query])
      @items = @items.by_koatuu(town.koatuu) unless params[:region].blank? and params[:role] != 'payers'
      @items = @items.where(:k_form.in => Modules::ClassifierType.find(params[:type])[:code]) unless params[:type].blank?
      @items.limit(10)
      respond_to do |format|
        format.html
        format.json
      end
    end

    def by_type
      # add 'where' filter if type was select
      @items = Modules::Classifier.all
      @items = items_by_koatuu unless params[:region].blank? and params[:role] != 'payers'
      @items = @items.where(:k_form.in => Modules::ClassifierType.find(params[:type])[:code]) unless params[:type].blank?

      direction = params[:sort_column].blank? || params[:sort_direction].eql?('asc') ? 1 : -1
      sort_col = params[:sort_column].present? ? params[:sort_column] : :pnaz
      @items = @items.order(sort_col => direction).page(params[:page]).per(10)

      @role = params[:role]
      # switch between '*.js.erb' depend on sorting params
      respond_to do |format|
        if params[:sort_column].blank?
          format.js
        else
          format.js { render 'modules/classifier/by_type_results' }
        end
        # format.json
      end
    end

    # TODO: Do refactor in future
    def import_dbf
      unless params[:file_name].nil?

        file = upload_file params[:file_name], params[:file_name].original_filename
        file_path = file[:path].to_s
        table = read_table_from_file file_path


        table.each do |row|

          if i < 5
            attributes = row.attributes
            web = Modules::Classifier.new
            if(web.fill_params attributes, types)
              # i=i+1
            end
          end
        end
      end
    end

    # TODO: Do refactor in future
    def all_classifier
      # @towns = Rails.cache.fetch("all_classifier", expiries: 1.month) do
      #   Modules::Classifier.all.group_by{|classf| classf.town_id}.transform_keys do |key|
      #     town = Town.where(id: key).first
      #     town_name = town.title unless town.nil?
      #     town_koatuu = town.koatuu unless town.nil?
      #     #binding.pry
      #     [key,town_name, town_koatuu]
      #   end
      # end
      @classf= Modules::Classifier.where(town:nil).all
      respond_to do |format|
        format.html { send_data @classf.to_csv, filename: "users-#{Date.today}.csv" }
        format.csv { send_data @classf.to_csv, filename: "users-#{Date.today}.csv" }
      end
      # classf.save
    end


    # TODO: Do refactor in future
    def all_classifier_region
      @regions = Rails.cache.fetch("all_classifier_region", expiries: 1.month) do
        Modules::Classifier.all.group_by{|classf| classf.sk_ter}
      end
      # @classf= Modules::Classifier.where(town:nil).all
      # respond_to do |format|
      #   format.html { send_data @classf.to_csv, filename: "users-#{Date.today}.csv" }
      #   format.csv { send_data @classf.to_csv, filename: "users-#{Date.today}.csv" }
      # end
      # classf.save
    end

    private
    # Copy from WidgetsController for show iframe in other sites
    def allow_iframe
      response.headers['x-frame-options'] = 'ALLOWALL'
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    end

    def sort_e_data
      # TODO: When first request to api cache with error:
      # SocketError (getaddrinfo: Name or service not known)
      # payments_data = Rails.cache.fetch("/edata/#{params[:payers_edrpous]}/#{params[:recipt_edrpous]}/#{params[:period]}",expiries_in: 1.day) do
      #   # Data
      #   ExternalApi::e_data_payments(params[:payers_edrpous], params[:recipt_edrpous], (start_date(params[:period]) unless params[:period].blank?), (end_date(params[:period]) unless params[:period].blank?))
      #   # Sort data
      # end
      payments_data = ExternalApi::e_data_payments(params[:payers_edrpous], params[:recipt_edrpous], (start_date(params[:period]) unless params[:period].blank?), (end_date(params[:period]) unless params[:period].blank?))

      sort_col = params[:sort_col].blank? ? 'trans_date' : params[:sort_col]
      unless payments_data.blank?
        payments_data.sort_by! do |hash|
          if sort_col.eql?('amount')
            hash[sort_col.to_s].to_f
          else
            hash[sort_col.to_s]
          end
        end
        payments_data.reverse! unless params[:sort_dir].eql?('asc')
      end
      # Results
      payments_data
    end

    def sort_data_bot
      # Data
      judicial_decisions = ExternalApi.data_bot_decisions(params[:edrpou])['warnings'][0]['decisions']
      # Sort data
      sort_col = params[:sort_col].blank? ? 'entry_date' : params[:sort_col]
      unless judicial_decisions.blank?
        judicial_decisions.sort_by! do |hash|
          hash[sort_col.to_s]
        end
        judicial_decisions.reverse! unless params[:sort_dir].eql?('asc')
      end
      # Results
      judicial_decisions
    end

    def start_date(period)
      format_date_for_api(period.split('/').first)
    end

    def end_date(period)
      format_date_for_api(period.split('/').last)
    end

    def format_date_for_api(date)
      date.to_date.strftime("%Y-%m-%d")
    end

    def items_by_koatuu
      Modules::Classifier.by_koatuu(town.koatuu)
    end

    def town
      @town = Town.find(params[:town_id])
    end
  end
end
