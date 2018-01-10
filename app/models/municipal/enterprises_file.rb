require 'file_size_validator'

class Municipal::EnterprisesFile
  include Mongoid::Document
  require 'carrierwave/mongoid'

  include Mongoid::Timestamps

  belongs_to :owner, class_name: 'User'
  belongs_to :town, class_name: 'Town'

  private
  mount_uploader :file, FileUploader

end
