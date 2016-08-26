namespace :repairing_restore_path do

  desc "restore url to files into repairing layers"

  task restore_file_path: :environment do
    # init path to folder repairing/layer
    folderspath = "#{Rails.public_path}/uploads/repairing/layer/repairs_file/"
    # init path to file into repairing/layer
    filepath = ''

    Repairing::Layer.all.each do |layers|
      if layers.repairs_file.url.nil?
        filepath = Dir.glob(folderspath + layers.id +  "/*")
        if filepath.empty?
          next
        else
          layers.repairs_file = File.open(filepath[0])
          layers.save
        end
      end
    end
  end

end