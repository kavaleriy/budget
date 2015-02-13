class Taxonomy
  include Mongoid::Document

  field :title, type: String
  field :owner, type: String

  field :columns_id, type: String
  field :columns, type: Hash

  field :explanation, :type => Hash

  before_save :generate_title

  has_many :budget_files, autosave: true, :dependent => :destroy

  def self.get_taxonomy(owner, columns)
    cols = {}
    columns.each { |col|
      cols[col] = { :level => cols.length + 1, :title => col } unless col == columns[columns.length - 1]
    }

    Taxonomy.where(:owner => owner, :columns_id => columns.join('_')).last || Taxonomy.create(
        :owner => owner,
        :columns_id => columns.join('_'),
        :columns => cols,
    )
  end

  def readline row
    amount_key = row.keys.last
    amount = row[amount_key].to_f
    return if amount.nil? || amount == 0

    line = {
        'amount' => amount,
    }

    row.keys.reject{|k| k == amount_key}.each {|r|
      val = row[r].to_s.split('.')[0]
      line[r] = val
    }

    line
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


  def get_tree
    rows = {}
    self.budget_files.each{ |file|
      file.rows.keys.each {|year|
        rows[year] = file.rows[year]
      }
    }

    create_tree rows
  end

  def get_range
    self.budget_files.map { |file| file.get_range }.flatten
  end

  def create_tree rows
    tree = { :amount => {} }

    # return nil if rows[year].nil? || rows[year][month].nil?

    rows.keys.each do |year|
      rows[year].keys.each do |month|
        rows[year][month].each do |row|
          node = tree
          node[:amount] = {} if node[:amount].nil?
          node[:amount][year] = {}  if node[:amount][year].nil?
          node[:amount][year][month] = 0  if node[:amount][year][month].nil?
          node[:amount][year][month] += row['amount']

          self.columns.keys.each { |taxonomy_key|
            taxonomy_value = row[taxonomy_key]

            if node[taxonomy_value].nil?
              node[taxonomy_value] = { :taxonomy => taxonomy_key, :amount => { year => { month => row['amount'] }} }
            else
              node[taxonomy_value][:amount][year] = {} if node[taxonomy_value][:amount][year].nil?
              logger.info(node[taxonomy_value][:amount][year])
              node[taxonomy_value][:amount][year][month] = 0 if node[taxonomy_value][:amount][year][month].nil?
              node[taxonomy_value][:amount][year][month] += row['amount']
            end

            node = node[taxonomy_value]
          }

        end
      end
    end

    create_tree_item(tree)
  end


  protected

  def create_tree_item(items, key = I18n.t('activerecord.models.taxonomy.node_key'))
    node = {
        'amount' => items[:amount],
        'key' => key,
        'taxonomy' => items[:taxonomy]
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


  def revenue_fond_codes
    @fond_info = load_from_csv 'db/revenue_fond_codes.csv' if @fond_info.nil?
    @fond_info
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

  def generate_title
    self.title = self.class if self.title.nil?
  end

  def load_from_csv file_name
    items = {}
    CSV.foreach(file_name, {:headers => true, :col_sep => ";"}) do |row|
      items[row[0]] = { title: row[I18n.t('activerecord.models.taxonomy.short_title')], color: row[I18n.t('activerecord.models.taxonomy.color')], icon: row[I18n.t('activerecord.models.taxonomy.icon')], description: row[I18n.t('activerecord.models.taxonomy.description')] }
    end
    items
  end

end
