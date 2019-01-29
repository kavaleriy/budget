namespace :properting_restore_path do

  desc "restore url to files into properting layers"

  task restore_file_path: :environment do
    # init path to folder properting/layer
    folderspath = "#{Rails.public_path}/uploads/properting/layer/properties_file/"
    # init path to file into properting/layer
    filepath = ''

    Properting::Layer.all.each do |layers|
      if layers.properties_file.url.nil?
        filepath = Dir.glob(folderspath + layers.id +  "/*")
        if filepath.empty?
          next
        else
          layers.properties_file = File.open(filepath[0])
          layers.save
        end
      end
    end
  end
end
