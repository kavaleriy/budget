class KeyIndicate::DictionaryFile
  include Mongoid::Document

  require 'carrierwave/mongoid'

  field :author, type: String
  field :title, type: String
  field :description, type: String

  has_many :key_indicate_dictionary_keys, :class_name => 'KeyIndicate::DictionaryKey', autosave: true, :dependent => :destroy
  belongs_to :key_indicate_dictionary, :class_name => 'KeyIndicate::Dictionary', autosave: true

  mount_uploader :dictionary_file, KeyIndicateDictionaryFileUploader
  skip_callback :update, :before, :store_previous_model_for_dictionary_file

  validates_presence_of :dictionary_file, message: 'Потрібно вибрати Файл'

  def import table
    table[:rows].each{|row|
      indicator = KeyIndicate::DictionaryKey.new
      row.each{|key, value|
        if key == 'key'
          indicator[key] = value.to_i.to_s.rjust(3,'0')
        else
          indicator[key] = value
        end
      }
      indicator.key_indicate_dictionary_file = self._id.to_s
      indicator.save
    }
  end

end
