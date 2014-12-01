class Taxonomy
  include Mongoid::Document

  field :name, type: String
  field :columns_id, type: String
  field :columns, type: Hash

  field :explanation, :type => Hash

  # embedded_in :budget_file
  has_many :budget_files, autosave: true

  def self.get_taxonomy(name, columns)
    cols = {}
    columns.each { |col|
      cols[col] = { :level => cols.length + 1, :title => col } unless col == columns[columns.length - 1]
    }

    Taxonomy.where(:name => name, :columns_id => columns.join('_')).last || Taxonomy.create(
        :name => name,
        :columns_id => columns.join('_'),
        :columns => cols
    )
  end

  def readline row
    amount_key = row.keys.last
    amount = row[amount_key].to_i
    return if amount.nil? || amount == 0

    row[amount_key] = amount

    row
  end

  def explain taxonomy, key
    self.explanation = { } if self.explanation.nil?
    self.explanation[taxonomy] = { } if self.explanation[taxonomy].nil?

    if self.explanation[taxonomy][key].nil?
      self.explanation[taxonomy][key] = get_taxonomy_info(taxonomy, key) || {}
    end
  end

  def get_taxonomy_info taxonomy, key
  end

  protected

  def revenue_codes
    @kkd_info = load_from_csv 'db/revenue_codes.csv' if @kkd_info.nil?
    @kkd_info
  end

  def expense_codes
    @ktfk_info = load_from_csv 'db/expense_codes.csv' if @ktfk_info.nil?
    @ktfk_info
  end

  def expense_ekv_codes
    @kekv_info = load_from_csv 'db/expense_ekv_codes.csv' if @kekv_info.nil?
    @kekv_info
  end

  def expense_kvk_codes
    @kvk_info = load_from_csv 'db/expense_kvk_codes.csv' if @kvk_info.nil?
    @kvk_info
  end

  private

  def load_from_csv file_name
    items = {}
    CSV.foreach(file_name, {:headers => true, :col_sep => ";"}) do |row|
      items[row[0]] = { title: row['Коротка назва'], color: row['Колір'], icon: row['Іконка'], description: row['Детальний опис'] }
    end
    items
  end



end
