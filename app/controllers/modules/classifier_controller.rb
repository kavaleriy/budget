module Modules
  class ClassifierController < ApplicationController
    before_action :town, only: [:search_data, :advanced_search, :by_type]
    respond_to :html, :js, :json

    def import_dbf
      #binding.pry
      unless params[:file_name].nil?
        data = File.open(params[:file_name].tempfile)
        widgets = DBF::Table.new(data, nil, 'cp866')
        #TODO: Do refactor in future
        i = 0
        widgets.each do |widget|
          #binding.pry
          if i < 20
            attributes = widget.attributes
            web = Modules::Classifier.new
            if(web.fill_params attributes)
              #i=i+1
            end
          end
        end
        #binding.pry
        # Zip::File.open('foo.zip') do |zip_file|
        #   # Handle entries one by one
        #   zip_file.each do |entry|
        #     # Extract to file/directory/symlink
        #     puts "Extracting #{entry.name}"
        #     entry.extract(dest_file)
        #
        #     # Read into memory
        #     content = entry.get_input_stream.read
        #   end
        #
        #   # Find specific entry
        #   entry = zip_file.glob('*.csv').first
        #   puts entry.get_input_stream.read
        # end
      end
    end

    def search_data
      # @items = Modules::Classifier.by_town(params["town_id"]).only(:id,:pnaz, :k_form).to_a
      # @town = Town.find(params["town_id"])
      @items = Modules::Classifier.by_koatuu(@town.koatuu).only(:id, :pnaz, :edrpou).to_a
      respond_with(@items, @town)
    end

    def prepare_data
      data = {}
      data['startdate'] = params['startdate'].blank? ? Time.now.months_since(-1).strftime("%d-%m-%Y") : params['startdate']
      data['enddate'] = Time.now.strftime("%d-%m-%Y")
      data['payers_edrpous'] = params['item_payer']
      data['recipt_edrpous'] = params['item_recipt']

      data["#{params['role']}_edrpous"] = params['item'] unless params['role'].blank?
      # if params['role'].blank?
      #   data['payers_edrpous'] = params['item_payer']
      #   data['recipt_edrpous'] = params['item_recipt']
      # else
      #   data["#{params['role']}_edrpous"] = params['item']
      # end
      data.delete_if { |key, value| value.blank? }
      data
    end

    def get_payments(data)
      uri = URI.parse('http://api.e-data.gov.ua:8080/api/rest/1.0/transactions')
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
      request.body = data.to_json
      JSON.parse(http.request(request).body)['response']['transactions'] rescue {}
    end

    def sort_e_data
      # Data
      data = prepare_data
      payments_data = get_payments(data)

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

    def search_e_data
      data = sort_e_data
      @payments = Kaminari.paginate_array(data).page(params[:page]).per(10)

      if params['sort_col'].blank?
        respond_to do |format|
          format.js
          format.json { render json: @payments }
          format.xls { send_data Modules::Classifier.to_xls(@payments) }
        end

      else
        respond_to do |format|
        format.js { render 'modules/classifier/sort_e_data' }
        end

      end
    end

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


    def advanced_search
      @types = Modules::ClassifierType.all
      # @town =  Town.find(params["town_id"])
      @items = Modules::Classifier.by_koatuu(@town.koatuu).only(:pnaz, :edrpou).to_a

      respond_with(@types, @items)
    end

    def by_type
      # @town = Town.find(params["town_id"])
      @items = Modules::Classifier.by_koatuu(@town.koatuu).where(k_form: params["type"]).to_a
      @role = params["role"]

      respond_with(@items)
    end

    private

    def town
      @town = Town.find(params["town_id"])
    end
  end
end
