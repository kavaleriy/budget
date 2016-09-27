module Modules
  class ClassifierController < ApplicationController
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
      @town = Town.find(params["town_id"])
      @items = Modules::Classifier.by_koatuu(@town.koatuu).only(:id, :pnaz, :knaz, :edrpou).to_a
      respond_with(@items, @town)
    end

    def select

    end


    def get_data(item)
      # read convention!
      # binding.pry
      data = {
          'startdate' => Time.now.months_since(-1).strftime("%d-%m-%Y"),
          'enddate' => Time.now.strftime("%d-%m-%Y")
          # 'startdate' => '30-09-2015',
          # 'enddate' => '30-09-2015',
      }
      role = params['role'].eql?('payer') ? 'payers_edrpous' : 'recipt_edrpous'
      data[role] = item.edrpou
      data['regions'] = item.sk_ter

      #data['recipt_edrpous'] = ["38054707"]
      # data['recipt_edrpous'] = params["edrpou"]
      data
    end

    def get_payments(data)
      # read conventions!
      # binding.pry
      uri = URI.parse('http://api.e-data.gov.ua:8080/api/rest/1.0/transactions')
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
      request.body = data.to_json
      #binding.pry
      JSON.parse(http.request(request).body)['response']['transactions'] rescue {}
    end


    def search_e_data
      # binding.pry
      item = Modules::Classifier::find(params["item"])

      data = get_data item
      @payments = get_payments(data).take(20)
      respond_to do |format|
        format.js
        format.json { render json: @payments }
        format.xls { send_data Modules::Classifier.to_xls(@payments) }
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
      # @items = Modules::Classifier.by_town(params["town_id"]).only(:id,:pnaz, :k_form).to_a
      @types = Modules::ClassifierType.all
      @town =  Town.find(params["town_id"])
      #binding.pry

      respond_with(@types, @town)
    end

    def by_type
      @town = Town.find(params["town_id"])
      @items = Modules::Classifier.by_koatuu(@town.koatuu).where(k_form: params["type"]).to_a
      @role = params["role"]
      respond_with(@items)
      #binding.pry
    end
  end
end
