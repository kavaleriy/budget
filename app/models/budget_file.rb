class BudgetFile
  include Mongoid::Document

  field :owner_email, type: String

  field :title, type: String
  field :name, type: String
  field :file, type: String

  # source data
  field :rows, :type => Array

  # list of taxonomies for tree levels
  has_one :taxonomy

  # calculated tree
  field :tree, :type => Hash

  field :meta_data, :type => Hash


  before_create :set_file, :set_taxonomy

  def set_owner
    self.owner_email = current_user.email unless current_user.nil?
  end

  def set_file
    self.title = self.name if self.title.nil?
  end

  def set_taxonomy

  end



  def self.get_revenue_codes
    load_from_csv 'db/revenue_codes.csv'
  end

  def self.get_expense_codes
    load_from_csv 'db/expense_codes.csv'
  end

  def self.get_expense_ekv_codes
    load_from_csv 'db/expense_ekv_codes.csv'
  end

  def self.get_expense_kvk_codes
    load_from_csv 'db/expense_kvk_codes.csv'
  end


  def load_file
    require 'roo'

    raw =
        case File.extname(self.file).downcase
          when '.csv'
            read_csv_xls Roo::CSV.new(self.file, csv_options: {col_sep: ";"})
          when '.xls', '.xlsx'
            xls = Roo::Excelx.new(self.file)
            xls.default_sheet = raw.sheets.first
            read_csv_xls xls
          when '.dbf'
            read_dbf DBF::Table.new(self.file)
        end

    # load taxonomies

    self.taxonomy = get_taxonomy(self.name, raw[:cols])

    # load raw data
    self.rows = raw[:rows]
  end

  def read_dbf(dbf)
    cols = dbf.columns.map {|c| c.name}

    rows = []
    dbf.reject { |rec| rec.summ.nil? || rec.summ == 0 }.each do |rec|
      key = rec.kkd.to_s
      amount = rec.summ / 100

      row = { :amount => amount }
      [{t: 'kkd_a', key: key.slice(0, 1)}, {t: 'kkd_bb', key: key.slice(0, 3)}, {t: 'kkd_cc', key: key.slice(0, 5)}, {t: 'kkd_ddd', key: key.slice(0, 8)}].each do |v|
        row[v[:t]] = v[:key]
      end
      rows << row
    end

    { :rows => rows, :cols => cols }
  end

  def read_csv_xls(xls)
    cols = []
    xls.first_column.upto(xls.last_column) { |col|
      col = xls.cell(1, col).to_s
      cols << col unless col.upcase == 'AMOUNT'
    }

    rows = []
    2.upto(xls.last_row) do |line|
      row = { :amount => xls.cell(line, xls.last_column).to_i }
      xls.first_column.upto(xls.last_column - 1) do |col|
        row[xls.cell(1, col).to_s] = xls.cell(line,col).to_s
      end
      rows << row unless row[:amount].to_i == 0
    end

    { :rows => rows, :cols => cols }
  end

  def prepare
    self.taxonomy.explanation = {}

    self.rows.each do |row|
      amount = row[:amount]

      row.keys.reject{|key| key == :amount}.each do |key|
        if self.taxonomy.explanation[key].nil?
          self.taxonomy.explanation[key] = { }
        end
        self.taxonomy.explanation[key][row[key]] = get_info(key, row[key])
      end
    end

    self.tree = create_tree
  end

  def get_info taxonomy, key
    info =
      case taxonomy
        when 'kkd', 'kkd_a', 'kkd_bb', 'kkd_cc', 'kkd_ddd'
          @kkd_info = BudgetFile.get_revenue_codes if @kkd_info.nil?
          @kkd_info[key.ljust(8, '0')]
        when 'ktfk'
          @ktfk_info = BudgetFile.get_expense_codes if @ktfk_info.nil?
          @ktfk_info[key]
        when 'kvk'
          @kvk_info = BudgetFile.get_expense_kvk_codes if @kvk_info.nil?
          @kvk_info[key]
        when 'kekv'
          @kekv_info = BudgetFile.get_expense_ekv_codes if @kekv_info.nil?
          @kekv_info[key]
      end
    info || {}
  end

 protected

    def self.load_from_csv file_name
      items = {}
      CSV.foreach(file_name, {:headers => true, :col_sep => ";"}) do |row|
        items[row[0]] = { title: row['Коротка назва'], color: row['Колір'], icon: row['Іконка'], description: row['Детальний опис'] }
      end
      items
    end

  def create_tree
    tree = { :amount => 0 }

    min = nil
    max = 0

    self.rows.each do |row|
      node = tree
      node[:amount] += row[:amount]
      self.taxonomy.columns.keys.each { |taxonomy_key|
        taxonomy_value = row[taxonomy_key]

        if node[taxonomy_value].nil?
          node[taxonomy_value] = { :taxonomy => taxonomy_key, :amount => row[:amount] }
        else
          node[taxonomy_value][:amount] += row[:amount]
        end

        min = node[taxonomy_value][:amount] if min.nil? || node[taxonomy_value][:amount].abs < min
        max = node[taxonomy_value][:amount] if node[taxonomy_value][:amount].abs > max
        node = node[taxonomy_value]
      }
    end

    self.meta_data = { :min => min, :max => max}

    create_tree_item(tree)
  end

  def create_tree_item(items, key = 'Всього')
    node = {
        'amount' => items[:amount],
        'key' => key,
        :taxonomy => items[:taxonomy]
    }

    children = items.keys.reject{|k| k == :amount || k == :taxonomy }

    unless children.empty?
      node['children'] = []
      children.each { |item_key|
        node['children'] << self.create_tree_item(items[item_key], item_key)
      }
    end

    node
  end

end
