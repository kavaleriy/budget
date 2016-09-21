module Modules
  class ClassifierController < ApplicationController
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
      @items = Modules::Classifier.by_town(params["town_id"]).only(:id,:pnaz).to_a


      #binding.pry
    end

    def get_data item
      #binding.pry
      data = {
          'startdate' => '30-09-2015',
          'enddate' => '30-09-2015',
      }

      data['payers_edrpous'] = [item.edrpou]
      data['regions'] = [item.sk_ter]
      #data['recipt_edrpous'] = ["38054707"]


      data['recipt_edrpous'] =params["edrpou"]


      data
        #binding.pry
      # data.delete_if { |key, value| value.blank? }

    end

    def get_payments data
      uri = URI.parse('http://api.e-data.gov.ua:8080/api/rest/1.0/transactions')
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
      request.body = data.to_json
      #binding.pry
      JSON.parse(http.request(request).body)['response']['transactions'] rescue {}
    end


    def search_e_data
      #binding.pry
      item = Modules::Classifier::find(params["item"])

      data = get_data item
      #binding.pry
      @payments = (get_payments data).take(20)
      #binding.pry
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
      #binding.pry
      @classf= Modules::Classifier.where(town:nil).all
      respond_to do |format|
        format.html { send_data @classf.to_csv, filename: "users-#{Date.today}.csv" }
        format.csv { send_data @classf.to_csv, filename: "users-#{Date.today}.csv" }
      end
      binding.pry
      # classf.save


      #binding.pry


    end


    def all_classifier_region
      @regions = Rails.cache.fetch("all_classifier_region", expiries: 1.month) do
        Modules::Classifier.all.group_by{|classf| classf.sk_ter}
      end
      binding.pry
      # @classf= Modules::Classifier.where(town:nil).all
      # respond_to do |format|
      #   format.html { send_data @classf.to_csv, filename: "users-#{Date.today}.csv" }
      #   format.csv { send_data @classf.to_csv, filename: "users-#{Date.today}.csv" }
      # end
      binding.pry
      # classf.save


      #binding.pry


    end

  end
end
