class KeyIndicate::Dictionary
  include Mongoid::Document

  has_many :key_indicate_dictionary_files, :class_name => 'KeyIndicate::DictionaryFile', autosave: true, :dependent => :destroy

  def get_keys
    keys = {}
    self.key_indicate_dictionary_files.each{|file|
      file.key_indicate_dictionary_keys.each{|key|
        keys[key['key']] = {}
        %w(indicator unit icon color type).each{|k|
          keys[key['key']][k] = key[k]
        }
      }
    }
    keys
  end

end
