class Taxonomy
  include Mongoid::Document

  field :title, type: String
  field :owner, type: String

  field :is_kvk, type: Boolean

  field :explanation, :type => Hash

  before_save :generate_title

  has_many :budget_files, autosave: true, :dependent => :destroy

  def self.visible_to user
    files = if user
      if user.has_role? :admin
        Taxonomy.all
      else
        Taxonomy.where(:owner => user.town).not{budget_files == nil}
      end
    else
      Taxonomy.where(:owner => '').not{budget_files == nil}
    end.sort_by { |t| t.owner || '' }

    files || []
  end

  def self.get_taxonomy(owner)
    self.where(:owner => owner).last || self.create!(
        :owner => owner,
    )
  end

  def explain taxonomy, key
    self.explanation = { } if self.explanation.nil?
    self.explanation[taxonomy] = { } if self.explanation[taxonomy].nil?

    if self.explanation[taxonomy][key].nil?
      self.explanation[taxonomy][key] = get_taxonomy_info(taxonomy, key) || {}
    end
  end

  def get_taxonomy_info taxonomy, key
    case taxonomy
      when 'fond'
        revenue_fond_codes[key]

      when 'kkd', 'kkd_a', 'kkd_bb', 'kkd_cc'
        revenue_codes[key.ljust(8, '0')]

      when 'ktfk'
        expense_codes[key] || expense_codes[key.rjust(5, '0')] || expense_codes[key.rjust(6, '0')]
      when 'ktfk_aaa'
        expense_codes[key.ljust(5, '0')] || expense_codes[key.ljust(6, '0')]
      when 'kvk'
        expense_kvk_codes[key.split(':')[0]]
      when 'kekv'
        expense_ekv_codes[key]
    end
  end

  def get_level level

    totals = {}

    rows = self.get_rows

    rows.each do |year, months|
      totals[year] = { } if totals[year].nil?

      months.each do |month, rows|
        totals[year][month] = 0 if totals[year][month].nil?

        rows.each do |row|
          totals[year][month] += row[:amount]
        end
      end
    end

    levels = {}
    explanation = self.explanation[level.to_s]
    rows.each do |year, months|
      months.each do |month, rows|
        rows.each do |row|
          key = row[level]

          if levels[key].nil?
            levels[key] = {}

            levels[key]['label'] = explanation[key]['title'] || key
            %w(icon color).map{|k|
              levels[key][k] = explanation[key][k]
            } unless explanation[key].nil?
          end

          levels[key][:amount] = {} if levels[key][:amount].nil?
          levels[key][:amount][year] = {} if levels[key][:amount][year].nil?
          levels[key][:amount][year][month] = 0 if levels[key][:amount][year][month].nil?
          levels[key][:amount][year][month] += row[:amount]
        end
      end
    end


    { totals: totals, levels: levels }
  end

  def get_level_with_fonds level
    levels = {}

    explanation = self.explanation[level.to_s]

    self.get_rows.each do |year, months|
      levels[year] = { } if levels[year].nil?

      levels[year][:totals] = {} if levels[year][:totals].nil?

      months.each do |month, rows|
        if levels[year][month].nil?
          levels[year][:totals][month] = 0
          levels[year][month] = { }
        end
        rows.each do |row|
          fond = row[:fond]
          if levels[year][month][fond].nil?
            levels[year][month][fond] = {  }
          end

          key = row[level]
          if levels[year][month][fond][key].nil?
            levels[year][month][fond][key] = { amount: 0 }
            %w(title icon color).map{|k|
              levels[year][month][fond][key][k] = explanation[key][k]
            }
          end

          levels[year][month][fond][key][:amount] += row[:amount]
          levels[year][:totals][month] += row[:amount]
        end
      end
    end

    levels
  end

  def get_tree
    rows = get_rows

    create_tree rows
  end

  def get_subtree level, key, filter
    rows = get_rows

    subrows = {}
    rows.keys.each {|year|
      subrows[year] = {} if subrows[year].nil?
      rows[year].keys.each { |month|
        subrows[year][month] = [] if subrows[year][month].nil?
        rows[year][month].each { |row|
          subrows[year][month] << row.reject{|k, v| k == level or filter.include?(k)} if row[level] == key
        }
      }
    }

    create_tree subrows, filter
  end

  def get_rows
    rows = {}
    self.budget_files.each{ |file|
      file.rows.keys.each {|year|
        rows[year] = {} if rows[year].nil?
        file.rows[year].keys.each {|month|
          rows[year][month] = file.rows[year][month]
        }
      }
    }
    rows
  end

  def get_range
    self.budget_files.map { |file| file.get_range }.flatten
  end

  def create_tree rows, filter = []
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

          self.columns.keys.reject{|k| filter.include?(k)}. each { |taxonomy_key|

            if row[taxonomy_key].nil?
              taxonomy_value = row['ktfk'].slice(0, row['ktfk'].length - 3)
            else
              taxonomy_value = row[taxonomy_key]
            end

            if node[taxonomy_value].nil?
              node[taxonomy_value] = { :taxonomy => taxonomy_key, :amount => { year => { month => row['amount'] }} }
            else
              node[taxonomy_value][:amount][year] = {} if node[taxonomy_value][:amount][year].nil?
              # logger.info(node[taxonomy_value][:amount][year])
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


  def revenue_codes
    @kkd_info = load_from_csv 'db/revenue_codes.csv' if @kkd_info.nil?
    @kkd_info
  end

  def expense_codes
    @ktfk_info = load_from_csv 'db/expense_codes.csv' if @ktfk_info.nil?
    @ktfk_info
  end

  def revenue_fond_codes
    @fond_info = load_from_csv 'db/revenue_fond_codes.csv' if @fond_info.nil?
    @fond_info
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
