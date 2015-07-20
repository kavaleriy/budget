class KeyIndicate::Town
  include Mongoid::Document

  field :title, type: String
  field :explanation, :type => Hash

  has_many :key_indicate_indicator_files, :class_name => 'KeyIndicate::IndicatorFile', autosave: true, :dependent => :destroy

  def generate_explanation
    self.explanation = self.load_from_csv 'db/key_indicators.csv'
  end

  protected

  def load_from_csv file_name
    items = {}
    CSV.foreach(file_name, {:headers => true, :col_sep => ";", :quote_char => '|'}) do |row|
      items[row[0]] = { key: row['key'], indicator: row['indicator'], unit: row['unit'], icon: row['icon'] }
    end
    items
  end
end
