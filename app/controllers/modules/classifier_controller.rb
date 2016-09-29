module Modules
  class ClassifierController < ApplicationController
    before_action :town, only: [:search_data, :advanced_search, :by_type]
    respond_to :html, :js, :json

    def search_data
      @items = Modules::Classifier.by_koatuu(@town.koatuu).only(:pnaz, :edrpou).to_a
      respond_with(@items, @town)
    end

    def search_e_data
      data = sort_e_data
      @payments = Kaminari.paginate_array(data).page(params[:page]).per(10)
      if params['sort_col'].blank?
        respond_to do |format|
          format.js { render 'modules/classifier/search_e_data' }
          format.json { render json: @payments }
          format.xls { send_data Modules::Classifier.to_xls(@payments) }
        end
      else
        respond_to do |format|
        format.js { render 'modules/classifier/sort_e_data' }
        end
      end
    end

    def advanced_search
      @types = Modules::ClassifierType.all
      @items = Modules::Classifier.by_koatuu(@town.koatuu).only(:pnaz, :edrpou).to_a
      respond_with(@types, @items)
    end

    def by_type
      @items = Modules::Classifier.by_koatuu(@town.koatuu).where(k_form: params["type"]).to_a
      @role = params["role"]
      respond_with(@items)
    end

    def import_dbf
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

    private

    def sort_e_data
      # Data
      payments_data = ExternalApi::e_data_payments(params['payers_edrpous'], params['recipt_edrpous'], params['startdate'])

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

    def town
      @town = Town.find(params["town_id"])
    end
  end
end
