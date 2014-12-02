class Taxonomy
  include Mongoid::Document

  field :owner, type: String
  field :columns_id, type: String
  field :columns, type: Hash

  field :explanation, :type => Hash

  # embedded_in :budget_file
  has_many :budget_files, autosave: true

  def self.get_taxonomy(owner, columns)
    cols = {}
    columns.each { |col|
      cols[col] = { :level => cols.length + 1, :title => col } unless col == columns[columns.length - 1]
    }

    Taxonomy.where(:owner => owner, :columns_id => columns.join('_')).last || Taxonomy.create(
        :owner => owner,
        :columns_id => columns.join('_'),
        :columns => cols
    )
  end

  def readline row
    amount_key = row.keys.last
    amount = row[amount_key].to_i
    return if amount.nil? || amount == 0

    row[amount_key] = amount

    row.keys.reject{|k| k == amount_key}.each {|r|
      val = row[r].to_s.split('.')[0]
      row[r] = val
    }

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


  def create_tree rows, year, month
    tree = { :amount => 0 }

    min = nil
    max = 0

    rows[year][month].each do |row|
      node = tree
      node[:amount] += row['amount']
      self.columns.keys.each { |taxonomy_key|
        taxonomy_value = row[taxonomy_key]

        if node[taxonomy_value].nil?
          node[taxonomy_value] = { :taxonomy => taxonomy_key, :amount => row['amount'] }
        else
          node[taxonomy_value][:amount] += row['amount']
        end

        min = node[taxonomy_value][:amount] if min.nil? || node[taxonomy_value][:amount].abs < min
        max = node[taxonomy_value][:amount] if node[taxonomy_value][:amount].abs > max
        node = node[taxonomy_value]
      }
    end

    { :tree => create_tree_item(tree), :min => min, :max => max}
  end


  protected

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
