module Modules
  class ClassifierController < ApplicationController
    before_action :town, only: [:search_data, :advanced_search, :by_type]

    def search_data
      @items = items_by_koatuu.only(:pnaz, :edrpou)
      respond_to do |format|
        format.html { render file: 'modules/classifier/search_data', layout: 'visify'}
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
      data = sort_e_data
      @payments = Kaminari.paginate_array(data).page(params[:page]).per(10) unless data.blank?

      # this variable are using for chart
      @receivers = ExternalApi::most_received(params[:payers_edrpous], params[:recipt_edrpous], (params[:period].split('/').first unless params[:period].blank?), (params[:period].split('/').last unless params[:period].blank?)).first(10)

      respond_to do |format|
        # TODO should be rewrite using as :template
        format.html {render 'modules/classifier/_search_e_data', layout: 'visify'}
        format.json { render json: @payments }
        format.csv { send_data Modules::Classifier.to_csv(data) }
        # switch between '*.js.erb' depend on sorting params
        if params[:sort_col].blank?
          format.js { render 'modules/classifier/search_e_data' }
        else
          format.js { render 'modules/classifier/sort_e_data' }
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
        data = File.open(params[:file_name].tempfile)
        widgets = DBF::Table.new(data, nil, 'cp866')
        #TODO: Do refactor in future
        i = 0
        types = Modules::ClassifierType.all_types
        #binding.pry

        widgets.each do |widget|

          if i < 5
            attributes = widget.attributes
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

    def sort_e_data
      # Data
      payments_data = ExternalApi::e_data_payments(params[:payers_edrpous], params[:recipt_edrpous], (params[:period].split('/').first unless params[:period].blank?), (params[:period].split('/').last unless params[:period].blank?))
      # Sort data
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

    def items_by_koatuu
      Modules::Classifier.by_koatuu(town.koatuu)
    end

    def town
      @town = Town.find(params[:town_id])
    end
  end
end
