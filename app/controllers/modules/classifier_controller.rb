module Modules
  class ClassifierController < AdminController
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

    def all_classifier
      @towns = Rails.cache.fetch("all_classifier", expiries: 1.month) do
        Modules::Classifier.all.group_by{|classf| classf.town_id}.transform_keys do |key|
          town = Town.where(id: key).first
          town_name = town.title unless town.nil?
          town_koatuu = town.koatuu unless town.nil?
          #binding.pry
          [key,town_name, town_koatuu]
        end
      end
      #binding.pry
      #classf= Modules::Classifier.find("57d9120da0fb4a525a003a1c")
      # @towns.each do |town,classf|
      #   binding.pry
      # end

      #binding.pry


    end

  end
end
