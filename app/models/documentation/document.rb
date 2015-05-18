class Documentation::Document
  include Mongoid::Document

  require 'carrierwave/mongoid'

  belongs_to :category, class_name: 'Documentation::Category', autosave: true

  field :title, type: String
  field :description, type: String
  field :issued, type: Time

  mount_uploader :doc_file, DocumentationUploader

  field :preview_ico, type: String
end
