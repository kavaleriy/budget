class BudgetFile
  include Mongoid::Document

  field :owner_email, type: String

  field :title, type: String
  field :file, type: String

  # source data
  field :rows, :type => Array

  # list of taxonomies for tree levels
  field :taxonomies, :type => Hash

  # calculated tree
  field :tree, :type => Hash

  # tree additional info
  field :tree_info, :type => Hash

  field :meta_data, :type => Hash


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


  def get_taxonomies cols
    taxonomies = {}
    cols.each { |col|
      level = taxonomies.length + 1
      taxonomies[col] = { :level => level, :title => "Рівень: #{level}" }
    }
    taxonomies
  end

  def load_file
    require 'roo'

    raw = nil

    if File.extname(self.file).downcase == '.csv'
      raw = Roo::CSV.new(self.file, csv_options: {col_sep: ";"})
    else
      raw = Roo::Excelx.new(self.file)
      raw.default_sheet = raw.sheets.first
    end

    # load taxonomies
    cols = []
    raw.first_column.upto(raw.last_column - 1) { |col| cols << raw.cell(1, col).to_s }
    self.taxonomies = get_taxonomies cols

    # load raw data
    self.rows = []
    2.upto(raw.last_row) do |line|
      row = { :amount => raw.cell(line, raw.last_column).to_i }
      raw.first_column.upto(raw.last_column - 1) do |col|
        row[raw.cell(1, col).to_s] = raw.cell(line,col).to_s
      end
      self.rows << row
    end
  end

  def prepare
    self.tree_info = {}

    self.rows.each do |row|
      amount = row[:amount]

      row.keys.reject{|key| key == :amount}.each do |key|
        if self.tree_info[key].nil?
          self.tree_info[key] = { }
        end
        self.tree_info[key][row[key]] = { title: get_title(key, row[key]) }
      end
    end

    self.tree = create_tree
  end

  def get_title taxonomy, key
    case taxonomy
      when 'kkd', 'kkd_a', 'kkd_bb', 'kkd_cc', 'kkd_ddd'
        @kkd_titles = BudgetFile.get_revenue_codes if @kkd_titles.nil?
        @kkd_titles[key.ljust(8, '0')]
      when 'ktfk'
        @ktfk_titles = BudgetFile.get_expense_codes if @ktfk_titles.nil?
        @ktfk_titles[key]
      when 'kvk'
        @kvk_titles = BudgetFile.get_expense_kvk_codes if @kvk_titles.nil?
        @kvk_titles[key]
      when 'kekv'
        @kekv_titles = BudgetFile.get_expense_ekv_codes if @kekv_titles.nil?
        @kekv_titles[key]
      else
        ''
    end
  end

  def get_bubble_tree
    get_bubble_tree_item(self.tree, { 'title' => 'Всього', 'color' => 'green', 'icon' => '/assets/icons/pig.svg' })
  end

  def get_bubble_tree_item(item, info)
    cut_amount = (self.meta_data[:max] - self.meta_data[:min]) * 0.00005

    node = {
        'size' => item[:amount],
        'amount' => (item[:amount]).abs,
        'name' => item[:taxonomy],
        'label' => item[:key],
    }

    if info
      node['label'] = info['name'] unless info['name'].nil?
      node['title'] = info['title'] unless info['title'].nil?
      node['color'] = info['color'] unless info['color'].nil?
      node['description'] = info['description'] unless info['description'].nil?
      node['icon'] = info['icon'] unless info['icon'].nil?
    end

    if item[:children].nil? || item[:children].length < 2
      node['color'] = '#BBBBBB'
    else
      node['color'] = '#265f91'
    end if node['color'].nil?

    unless item[:children].nil?
      node['children'] = []
      item[:children].each { |child_node|
        node['children'] << get_bubble_tree_item(child_node, self.tree_info[child_node[:taxonomy]][child_node[:key]]) if child_node[:amount] > cut_amount
      }
    end

    node
  end

  def get_sunburst_tree
    get_bubble_tree_item(self.tree, { 'title' => 'Всього', 'color' => 'green' })
  end

  protected

    def self.load_from_csv file_name
      items = {}
      CSV.foreach(file_name, {:headers => true, :col_sep => ";"}) do |row|
        items[row[0]] = row[1]
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
      self.taxonomies.keys.each { |taxonomy_key|
        taxonomy_value = row[taxonomy_key]

        if node[taxonomy_value].nil?
          node[taxonomy_value] = { :taxonomy => taxonomy_key, :amount => row[:amount] }
        else
          node[taxonomy_value][:amount] += row[:amount]
        end

        min = node[taxonomy_value][:amount] if min.nil? || node[taxonomy_value][:amount] < min
        max = node[taxonomy_value][:amount] if node[taxonomy_value][:amount] > max
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
