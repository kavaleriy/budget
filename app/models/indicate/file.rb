class Indicate::File
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String
  field :path, type: String

  embeds_many :indicate, class_name: 'Indicate::Indicator', autosave: true, :dependent => :destroy


  mount_uploader :indicate_file, IndicateUploader
  skip_callback :update, :before, :store_previous_model_for_indicate_file

  validates_presence_of :indicate_file, message: 'Потрібно вибрати Файл'


  def import table
    rows = {}

    table[:rows].each_with_index{|row, i|
      rows[i] = row
    }

    self.rows = rows
  end

end
