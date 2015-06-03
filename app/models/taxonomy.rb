class Taxonomy
  include Mongoid::Document

  before_save :generate_title

  field :title, type: String
  field :owner, type: String

  field :is_kvk, type: Boolean

  field :explanation, :type => Hash

  has_many :budget_files, autosave: true, :dependent => :destroy
  embeds_many :taxonomy_attachments

  def self.visible_to user
    files = if user && user.is_locked? == false
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

  def explain taxonomy, key
    return if key.nil?
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

      when 'kkd', 'kkd_a', '_kkd_a', 'kkd_bb', 'kkd_cc'
        revenue_codes[key.ljust(8, '0')]

      when 'ktfk'
        expense_codes[key] || expense_codes[key.ljust(5, '0')] || expense_codes[key.ljust(6, '0')]
      when 'ktfk_aaa'
        # expense_codes[key.ljust(5, '0')] || expense_codes[key.ljust(6, '0')]
        expense_codes["#{key}000"]
      when 'kvk'
        expense_kvk_codes[key.split(':')[0]]
      when 'kekv'
        expense_ekv_codes[key]
    end
  end

  def get_level level

    totals = {}

    rows = self.get_rows

    rows[:plan].each do |year, months|
      totals[year] = { } if totals[year].nil?

      months.each do |month, rows|
        totals[year][month] = 0 if totals[year][month].nil?

        rows.each do |row|
          totals[year][month] += row[:amount]
        end
      end
    end

    for i in 0..3
      totals.each do |year, months|
        totals[year]['quarters'] = [] if totals[year]['quarters'].nil?
        totals[year]['quarters'][i+1] = 0 if totals[year]['quarters'][i+1].nil?
        j = i*3 + 1
        while j < i*3 + 4
          totals[year]['quarters'][i+1] += months[j.to_s]
          j = j + 1
        end
      end
    end

    levels = {}
    explanation = self.explanation[level.to_s]
    rows[:plan].each do |year, months|
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

    for i in 0..3
      levels.each do |key, value|
        value['quarters'] = {} if value['quarters'].nil?
        value[:amount].each do |year, months|
          value['quarters'][year] = [] if value['quarters'][year].nil?
          value['quarters'][year][i+1] = 0 if value['quarters'][year][i+1].nil?
          j = i*3 + 1
          while j < i*3 + 4
            value['quarters'][year][i+1] += months[j.to_s]
            j = j + 1
          end
        end
      end
    end

    { totals: totals, levels: levels }
  end

  def get_level_with_fonds level
    levels = {}

    explanation = self.explanation[level.to_s]

    self.get_rows[:plan].each do |year, months|
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

  def get_tree levels
    rows = get_rows

    create_tree rows, [], levels
  end

  def get_subtree level, key, filter
    subrows = get_subrows level, key, filter

    create_tree subrows, filter
  end

  def get_subrows level, key, filter, rows = get_rows

    subrows = {}
    rows.keys.each { |data_type|
      subrows[data_type] = {} if subrows[data_type].nil?
      rows[data_type].keys.each { |year|
        subrows[data_type][year] = {} if subrows[data_type][year].nil?
        rows[data_type][year].keys.each { |month|
          subrows[data_type][year][month] = [] if subrows[data_type][year][month].nil?
          rows[data_type][year][month].each { |row|
            subrows[data_type][year][month] << row.reject{|k, v| k == level or filter.include?(k)} if row[level] == key
          }
        }
      }
    }

    subrows
  end

  def get_plan_fact_rows
    rows = { :plan => {}, :fact => {} }
    self.budget_files.each{ |file|
      type = file.type.to_sym
      file.rows.keys.each {|year|
        rows[type][year] = {} if rows[type][year].nil?
        file.rows[year].keys.each {|month|
          rows[type][year][month] = file.rows[year][month]
        }
      }
    }
    rows
  end

  def get_rows
    rows = { }
    self.budget_files.each{ |file|
      data_type = file.data_type

      file.rows.keys.each {|year|
        file.rows[year].keys.each {|month|
          rows[data_type] = {} if rows[data_type].nil?
          rows[data_type][year] = {} if rows[data_type][year].nil?
          if rows[data_type][year][month].nil?
            rows[data_type][year][month] = file.rows[year][month]
          else
            rows[data_type][year][month] += file.rows[year][month].flatten
          end
        }
      }
    }
    rows
  end

  def get_range
    self.budget_files.map { |file| file.get_range }.flatten
  end

  def create_tree rows, filter = [], levels = []
    tree = create_tree_sceleton rows, filter, levels
    create_tree_item(tree)
  end

  protected

  def create_tree_sceleton rows, filter = [], levels = []
    tree = { :amount => {} }
    # return nil if rows[year].nil? || rows[year][month].nil?
    if levels == []
      columns = self.columns.keys.reject{|k| filter.include?(k)}
    else
      columns = levels
    end

    rows.keys.each do |dt|
      rows[dt].keys.each do |year|
        rows[dt][year].keys.each do |month|
          rows[dt][year][month].each do |row|
            node = tree

            data_type = row['_amount_type'] || dt
            fond = row['fond']

            node[:amount] = {} if node[:amount].nil?
            node[:amount][data_type] = {}  if node[:amount][data_type].nil?
            node[:amount][data_type][year] = {}  if node[:amount][data_type][year].nil?
            node[:amount][data_type][year][month] = {}  if node[:amount][data_type][year][month].nil?
            node[:amount][data_type][year][month]['total'] = 0 if node[:amount][data_type][year][month]['total'].nil?
            node[:amount][data_type][year][month]['total'] += row['amount']
            unless fond.nil?
              node[:amount][data_type][year][month]['fonds'] = {} if node[:amount][data_type][year][month]['fonds'].nil?
              node[:amount][data_type][year][month]['fonds'][fond] = 0 if node[:amount][data_type][year][month]['fonds'][fond].nil?
              node[:amount][data_type][year][month]['fonds'][fond] += row['amount']
            end

            columns.each { |taxonomy_key|
              if row[taxonomy_key].nil?
                next unless taxonomy_key == 'ktfk_aaa'
                taxonomy_value = row['ktfk'].slice(0, row['ktfk'].length - 3)
              else
                taxonomy_value = row[taxonomy_key]
              end

              if node[taxonomy_value].nil?
                node[taxonomy_value] = { :taxonomy => taxonomy_key, :amount => { data_type => { year => { month => { 'total' => row['amount'] }}}} }
                node[taxonomy_value][:amount][data_type][year][month]['fonds'] = {}
                node[taxonomy_value][:amount][data_type][year][month]['fonds'][fond] = row['amount'] unless fond.nil?
              else
                node[taxonomy_value][:amount][data_type] = {} if node[taxonomy_value][:amount][data_type].nil?
                node[taxonomy_value][:amount][data_type][year] = {} if node[taxonomy_value][:amount][data_type][year].nil?
                node[taxonomy_value][:amount][data_type][year][month] = {} if node[taxonomy_value][:amount][data_type][year][month].nil?
                node[taxonomy_value][:amount][data_type][year][month]['total'] = 0 if node[taxonomy_value][:amount][data_type][year][month]['total'].nil?
                node[taxonomy_value][:amount][data_type][year][month]['total'] += row['amount']

                unless fond.nil?
                  node[taxonomy_value][:amount][data_type][year][month]['fonds'] = {} if node[taxonomy_value][:amount][data_type][year][month]['fonds'].nil?
                  node[taxonomy_value][:amount][data_type][year][month]['fonds'][fond] = 0 if node[taxonomy_value][:amount][data_type][year][month]['fonds'][fond].nil?
                  node[taxonomy_value][:amount][data_type][year][month]['fonds'][fond] += row['amount']
                end
              end

              node = node[taxonomy_value]
            }
          end
        end
      end
    end

    tree
  end

  def create_tree_item(items, key = I18n.t('mongoid.taxonomy.node_key'))
    node = {
        'amount' => items[:amount],
        'key' => key,
        'taxonomy' => items[:taxonomy]
    }

    children = items.keys.reject{|k| k.in?([:amount, :taxonomy]) }

    unless children.empty?
      node['children'] = []
      children.each { |item_key|
        node['children'] << self.create_tree_item(items[item_key], item_key)
      }
    end

    node
  end


  def revenue_codes
    @kkd_info = Taxonomy.load_from_csv 'db/revenue_codes.csv' if @kkd_info.nil?
    @kkd_info
  end

  def expense_codes
    @ktfk_info = Taxonomy.load_from_csv 'db/expense_codes.csv' if @ktfk_info.nil?
    @ktfk_info
  end

  def self.fond_codes
    Taxonomy.load_from_csv 'db/revenue_fond_codes.csv'
  end

  def revenue_fond_codes
    @fond_info = Taxonomy.load_from_csv 'db/revenue_fond_codes.csv' if @fond_info.nil?
    @fond_info
  end

  def expense_ekv_codes
    @kekv_info = Taxonomy.load_from_csv 'db/expense_ekv_codes.csv' if @kekv_info.nil?
    @kekv_info
  end

  def expense_kvk_codes
    @kvk_info = Taxonomy.load_from_csv 'db/expense_kvk_codes.csv' if @kvk_info.nil?
    @kvk_info
  end

  protected

  def self.load_from_csv file_name
    items = {}
    CSV.foreach(file_name, {:headers => true, :col_sep => ";"}) do |row|
      items[row[0]] = { title: row[I18n.t('mongoid.taxonomy.short_title')], color: row[I18n.t('mongoid.taxonomy.color')], icon: row[I18n.t('mongoid.taxonomy.icon')], description: row[I18n.t('mongoid.taxonomy.description')] }
    end
    items
  end

  private

  def generate_title
    self.title = self.class if self.title.nil?
  end

end
