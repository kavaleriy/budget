class Programs::Branch
  include Mongoid::Document

  field :name, type: String
  field :explanation, :type => Hash

  has_many :programs_target_programs, :class_name => 'Programs::TargetProgram', autosave: true, :dependent => :destroy
  has_many :programs_expences_files, :class_name => 'Programs::ExpencesFile', autosave: true, :dependent => :destroy
  has_many :programs_indicator_files, :class_name => 'Programs::IndicatorFile', autosave: true, :dependent => :destroy

  def generate_explanation
    self.explanation = {}
    self.explanation['kfkv'] = self.load_from_csv 'db/functions_kfkv_codes.csv'    # functional code (branch of a program)
    self.explanation['kvkv'] = self.load_from_csv 'db/departments_kvkv_codes.csv'  # chief steward (department)
    self.explanation['sub_kvkv'] = {}   # main executor under chief steward (vary for different cities and departments, that's why empty)
  end

  protected

  def load_from_csv file_name
    items = {}
    CSV.foreach(file_name, {:headers => true, :col_sep => ";", :quote_char => '|'}) do |row|
      items[row[0]] = { title: row[I18n.t('mongoid.taxonomy.short_title')], color: row[I18n.t('mongoid.taxonomy.color')], icon: row[I18n.t('mongoid.taxonomy.icon')], description: row[I18n.t('mongoid.taxonomy.description')] }
    end
    items
  end

end
