class Repairing::Category
  include Mongoid::Document

  field :title, type: String

  require 'carrierwave/mongoid'
  mount_uploader :img, CategoryImgUploader
  skip_callback :update, :before, :store_previous_model_for_img

  has_many :repairs, class_name: 'Repairing::Repair', autosave: true, :dependent => :destroy
end
