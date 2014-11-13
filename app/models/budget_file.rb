class BudgetFile
  include Mongoid::Document

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
    self.taxonomies = {}
    raw.first_column.upto(raw.last_column - 1) do |col|
      self.taxonomies[raw.cell(1, col)] = { :title => raw.cell(1, col) }
    end

    # load raw data
    self.rows = []
    2.upto(raw.last_row) do |line|
      row = { :amount => raw.cell(line, raw.last_column).to_i }
      raw.first_column.upto(raw.last_column - 1) do |col|
        row[raw.cell(1, col)] = raw.cell(line,col)
      end
      self.rows << row
    end
  end

  def prepare
    self.tree_info = { 'Всього' => { 'title' => 'Всього', 'color' => 'green' }}

    min = nil
    max = 0

    self.rows.each do |row|
      amount = row[:amount]
      min = amount if min.nil? || amount < min
      max = amount if amount > max

      row.keys.reject{|key| key == :amount}.each do |key|
        self.tree_info[key] = { title: self.taxonomies[key][:title]} if self.tree_info[key].nil?
        self.tree_info[key][row[key]] = { title: get_title(row[key]), color: 'orange' }
      end
    end

    self.meta_data = { :min => min, :max => max}

    self.tree = create_tree
  end

  def get_title key
    ''
  end

  def get_bubble_tree
    get_bubble_tree_item(self.tree)
  end

  def get_bubble_tree_item(item, key = 'Всього')
    if item[:amount] > 0
      node = {
          'size' => item[:amount],
          'amount' => item[:amount],
          'name' => 'name',
          'label' => 'label',
      }

      info = if item[:taxonomy].nil?
               self.tree_info[item[:key]]
             else
               self.tree_info[item[:taxonomy]][item[:key]]
             end
      if info
        node['label'] = info['name'] unless info['name'].nil?
        node['title'] = info['title'] unless info['title'].nil?
        node['color'] = info['color'] unless info['color'].nil?
        node['description'] = info['description'] unless info['description'].nil?
      end

      node['color'] = 'orange' if node['color'].nil?

      unless item[:children].nil?
        node['children'] = []
        item[:children].each { |child_node|
          node['children'] << get_bubble_tree_item(child_node)
        }
      end

      node
    end
  end

  def get_sunburst_tree
    get_bubble_tree_item(self.tree)
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
        node = node[taxonomy_value]
      }
    end

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
