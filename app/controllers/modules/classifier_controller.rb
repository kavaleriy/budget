module Modules
  class ClassifierController < ApplicationController
    before_action :town, only: [:e_data, :search_data, :advanced_search, :by_type]
    respond_to :html, :js, :json

    def search_data
      @items = items_by_koatuu.only(:pnaz, :edrpou).to_a
      respond_with(@items, layout: 'visify' )
    end

    def direct_link
      # access from direct link (socials networks)
      @items = items_by_koatuu.only(:pnaz, :edrpou).to_a
      respond_to do |format|
        format.html { render 'modules/classifier/share_search' }
      end
    end

    def search_e_data
      binding.pry
      data = sort_e_data
      @payments = Kaminari.paginate_array(data).page(params[:page]).per(10) unless data.nil?
      # this variable are using for chart
      @receivers = ExternalApi::most_received(params['payers_edrpous'], params['recipt_edrpous']).first(10)

      # switch between '*.js.erb' depend on sorting params
      if params['sort_col'].blank?
        # respond_with(@payments, @receivers)
        respond_to do |format|
          # TODO should be rewrite using as :template
          format.html {render 'modules/classifier/_search_e_data', layout: 'visify'}
          format.js { render 'modules/classifier/search_e_data' }
          format.json { render json: @payments }
          format.csv { send_data Modules::Classifier.to_csv(data) }
        end
      else
        respond_to do |format|
        format.js { render 'modules/classifier/sort_e_data' }
        end
      end
    end

    def advanced_search
      @types_payer = Modules::ClassifierType.where(payer: true).all
      @types_receipt = Modules::ClassifierType.where(receipt: true).all
      @items = items_by_koatuu.only(:pnaz, :edrpou).to_a.sort_by! { |hash| hash.pnaz }
      respond_with(@types, @items, layout: 'visify')
    end

    def select_collection
      # binding.pry
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
      # binding.pry
      # add 'where' filter if type was select
      @items = (params["type"].blank? ? items_by_koatuu : items_by_koatuu.where(:k_form.in=> Modules::ClassifierType.find(params[:type])[:code])).to_a.sort_by! do |hash|
        if params['sort_column'].blank?
          # use default sorting if sorting params empty
          hash.pnaz
        else
          hash[params['sort_column']]
        end
      end
      @items.reverse! unless params['sort_column'].blank? || params['sort_direction'].eql?('asc')
      @items = Kaminari.paginate_array(@items).page(params[:page]).per(10)
      @role = params["role"]
      # switch between '*.js.erb' depend on sorting params
      respond_to do |format|
        if params['sort_column'].blank?
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
      payments_data = ExternalApi::e_data_payments(
          params['payers_edrpous'],
          params['recipt_edrpous'],
          (params['period'].split('/').first unless params['period'].blank?),
          (params['period'].split('/').last unless params['period'].blank?)
      )
      # Sort data
      sort_col = params['sort_col'].blank? ? 'trans_date' : params['sort_col']
      unless payments_data.nil?
        payments_data.sort_by! do |hash|
          if sort_col.eql?('amount')
            hash[sort_col.to_s].to_f
          else
            hash[sort_col.to_s]
          end
        end
        payments_data.reverse! unless params['sort_dir'].eql?('asc')
      end
      # Results
      payments_data
    end

    def items_by_koatuu
      #binding.pry
      # Modules::Classifier.by_koatuu(town.koatuu, town.koatuu[2..10].eql?('00000000') ? 2 : 5)
      Modules::Classifier.by_koatuu(town.koatuu)
    end

    def town
      @town = Town.find(params[:town_id])
    end
  end
end
