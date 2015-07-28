class KeyIndicate::DictionaryKey
  include Mongoid::Document

  field :key, type: String
  field :indicator, type: String
  field :unit, type: String
  field :icon, type: String
  field :color, type: String
  field :type, type: String

  belongs_to :key_indicate_dictionary_file, :class_name => 'KeyIndicate::DictionaryFile', autosave: true

  validates_uniqueness_of :key

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv.add_row ["id", "key", "indicator", "unit"]
      all.each do |foo|
        values = foo.attributes.values
        csv.add_row values
      end
    end
  end

end
