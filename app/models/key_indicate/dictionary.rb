class KeyIndicate::Dictionary
  include Mongoid::Document

  has_many :key_indicate_dictionary_files, :class_name => 'KeyIndicate::DictionaryFile', autosave: true, :dependent => :destroy

end
