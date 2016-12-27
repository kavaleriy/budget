  class Taxonomy
    include Mongoid::Document
    include Mongoid::Timestamps

    scope :by_town, lambda { |town| where(town: town) }
    # select taxonomies belongs to town
    # scope :owned_by, lambda { |town| where(:owner => town) }
    # select all active taxonomies
    scope :get_active, -> { where(active: true ) }
    # select taxonomies by town id
    scope :by_town_id, lambda { |town_id| where(:town_id => town_id) }
    scope :get_by_ids, lambda { |ids| where(:id.in => ids) }

    before_save :generate_title

    attr_accessor :locale

    field :title, type: String
    field :name, type: String
    field :description, type: String
    field :owner, type: String
    field :is_kvk, type: Boolean
    field :explanation, :type => Hash
    field :area, :type => String # код області
    field :kmb, :type => String # код місцевого бюджета
    field :active, type: Boolean

    embeds_many :recipients, class_name: 'TaxonomyRecipient'

    belongs_to :author, class_name: 'User'
    has_many :budget_files, autosave: true, :dependent => :destroy
    has_many :taxonomy_attachments, :class_name => 'TaxonomyAttachment', autosave: true, :dependent => :destroy
    belongs_to :town, class_name: 'Town'


    def self.active_or_first_by_town(town)
      res = self.by_town(town).get_active.first
      if res.nil?
        res = self.by_town(town).first
      end
      res
    end

    # def self.get_active_by_town(town)
    #   # get active taxonomies belongs to town
    #   self.owned_by(town).get_active
    # end

    def self.active_taxonomies_by_town(town_id)
      self.by_town_id(town_id).get_active
      # self.by_town_id(town_id) # for open town programs with old data
    end

    def self.get_active_for_all_towns
      # this function grouped taxonomies by town
      # and return array of hashes active or first taxonomies from town
      taxonomies_group_by_town = self.all.group_by{|f| f.town}.keys.compact
      result = []

      taxonomies_group_by_town.each do |town|
        taxonomy = self.active_or_first_by_town(town)

        # get town blazon if town exist and town have img
        town_blazon = town.img.url unless town.nil? || town.img.nil?

        town_name = town.title unless town.blank?

        # push taxonomy with blazon
        unless town_name.blank?
          result << {
              id: taxonomy.id.to_s,
              title: taxonomy.title,
              town_name: town_name,
              img: town_blazon
          }
        end
      end
      result
    end

    def self.check_switch_plan_fact(tax_rot_id,tax_rov_id)
      # this function chheck if we can switch plan fact data
      # get two params TaxonomyRot id , and TaxonomyRov id
      # first of all we find these taxonomies
      # after that we group budget files for these taxonomies
      # count these group and if these group more than 1
      # return true
      # else return false

      tax_rot = TaxonomyRot.find(tax_rot_id)
      tax_rov = TaxonomyRov.find(tax_rov_id)

      tax_rot.count_budget_files_by_data_type > 1 && tax_rov.count_budget_files_by_data_type > 1
    end

    def count_budget_files_by_data_type
      # this function group budget files by data_type and return count of group
      budget_files.group_by{|f| f.data_type}.count
    end

    def self.visible_to user
      files = if user && user.is_locked? == false
                if user.has_role? :admin
                  self.all
                else
                  self.where(:town => user.town_model,:author.in => [user,nil])
                end
              else
                self.where(:owner => '')
              end

      files
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

        when 'kkd_a', 'kkd_b', 'kkd_cc', 'kkd_dd', 'kkd'
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
        when 'krk'
          expense_krk_codes[key]
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


    def get_level_with_fonds level,type
      levels = {}

      explanation = self.explanation[level.to_s]

      test = self.get_plan_fact_rows[type.to_sym]

      unless test.nil?
        test.each do |year, months|

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
                levels[year][month][fond] = {}
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

      rows.keys.each { |year|
        subrows[year] = {} if subrows[year].nil?
        rows[year].keys.each { |month|
          subrows[year][month] = [] if subrows[year][month].nil?
          rows[year][month].each { |row|
            subrows[year][month] << row.reject{|k, v| k == level or filter.include?(k)} if row[level] == key
          }
        }
      }

      subrows
    end


    def get_plan_fact_rows
      rows = {}
      self.budget_files.each{ |file|
        data_type = file.data_type.blank? ? :plan : file.data_type.to_sym

        file.rows.keys.each {|year|
          file.rows[year].keys.each {|month|
            file.rows[year][month].each { |row|
              _data_type = row['_amount_type'].blank? ? data_type : row['_amount_type'].to_sym
              rows[_data_type] = {} if rows[_data_type].nil?
              rows[_data_type][year] = {} if rows[_data_type][year].nil?
              rows[_data_type][year][month] = [] if rows[_data_type][year][month].nil?
              rows[_data_type][year][month] << row
            }
          }
        }
      }
      rows
    end

    def get_rows
      combined_rows = {}

      self.budget_files.collect { |file| file.get_rows }.collect{ |rows|
        combined_rows.deep_merge!(rows){ |key, this_val, other_val| this_val + other_val }
      }

      combined_rows
    end

    def get_range
      self.budget_files.map { |file| file.get_range }.flatten
    end

    def create_tree rows, filter = [], levels = []
      tree = create_tree_sceleton rows, filter, levels
      create_tree_item(tree)
    end

    # get only total amounts (without levels and fonds) only for years (0 month)
    # used in public/towns profile for revenues_expences view
    def get_total_amounts
      rows = { }
      self.budget_files.each{ |file|
        data_type = file.data_type
        data_type = :plan if data_type.blank?

        file.rows.keys.each {|year|
          rows[data_type] = {} if rows[data_type].nil?
          if rows[data_type][year].nil?
            rows[data_type][year] = file.rows[year]['0']
          else
            rows[data_type][year] += file.rows[year]['0'].flatten
          end
        }
      }

      node = {}

      rows.keys.each do |dt|
        rows[dt].keys.each do |year|
          rows[dt][year].each do |row|
            data_type = row['_amount_type'] || dt
            node[data_type] = {}  if node[data_type].nil?
            node[data_type][year] = {}  if node[data_type][year].nil?
            node[data_type][year] = {}  if node[data_type][year].nil?
            node[data_type][year]['total'] = 0 if node[data_type][year]['total'].nil?
            node[data_type][year]['total'] += row['amount']
          end
        end
      end

      node
    end

    def get_author
      unless author.nil?
        author.organisation || author.email
      end
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

      rows.keys.each do |year|
        rows[year].keys.sort.each do |month|
          rows[year][month].each do |row|
            node = tree

            data_type = row['_amount_type']
            fond = row['fond'] || ''

            node[:amount] = {} if node[:amount].nil?
            node[:amount][data_type] = {}  if node[:amount][data_type].nil?
            node[:amount][data_type]['_cumulative'] = row['_cumulative']
            node[:amount][data_type][year] = {}  if node[:amount][data_type][year].nil?
            node[:amount][data_type][year][month] = {}  if node[:amount][data_type][year][month].nil?
            node[:amount][data_type][year][month]['total'] = 0 if node[:amount][data_type][year][month]['total'].nil?
            node[:amount][data_type][year][month]['total'] += row['amount']

            node[:amount][data_type][year][month]['fonds'] = {} if node[:amount][data_type][year][month]['fonds'].nil?
            node[:amount][data_type][year][month]['fonds'][fond] = 0 if node[:amount][data_type][year][month]['fonds'][fond].nil?
            node[:amount][data_type][year][month]['fonds'][fond] += row['amount']

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

              node[taxonomy_value][:amount][data_type]['_cumulative'] = row['_cumulative']

              node = node[taxonomy_value]
            }
          end
        end
      end
      tree
    end

    def create_tree_item(items, key = I18n.t('mongoid.taxonomy.in_total'))
      node = {
          'amount' => items[:amount],
          'key' => key,
          'taxonomy' => items[:taxonomy]
      }

      if node['amount'][:fact] and node['amount'][:fact]['_cumulative']
        node['amount'][:fact].each{ |year, months|
          next if year == '_cumulative'
          next if months.length == 1
          last_month = months.keys.max_by{|k| k.to_i}
          annual = months[last_month].deep_dup
          Hash[months.sort_by{|k, v| k.to_i}.reverse].each_key{ |month|

            prev_month = "#{month.to_i - 1}"
            next if prev_month == '0'

            if months[prev_month]
              months[month]['total'] -= months[prev_month]['total']

              if months[prev_month]['fonds']
                months[month]['fonds'].each_key{ |fond| months[month]['fonds'][fond] = months[month]['fonds'][fond] - months[prev_month]['fonds'][fond] if months[prev_month]['fonds'][fond]}
              end

              months.delete(month) if months[month]['total'] == 0
            end
          }
          months['0'] = annual
        }
      end

      if node['amount'][:plan] and node['amount'][:plan]['_cumulative']
        node['amount'][:plan].each{ |year, months|
          next if year == '_cumulative'
          next if months.length == 1
          last_month = months.keys.max_by{|k| k.to_i}
          annual = months[last_month].deep_dup

          Hash[months.sort_by{|k, v| k.to_i}.reverse].each_key{ |month|
            months[month]['total'] = months[month]['total'] / 12
            months[month]['fonds'].each_key{ |fond| months[month]['fonds'][fond] = months[month]['fonds'][fond] / 12 }

            prev_month = "#{month.to_i - 1}"
            next if prev_month == '0'

            if months[prev_month]
              # months[month]['total'] -= months[prev_month]['total']
              #
              # if months[prev_month]['fonds']
              #   months[month]['fonds'].each_key{ |fond| months[month]['fonds'][fond] = months[month]['fonds'][fond] - months[prev_month]['fonds'][fond] if months[prev_month]['fonds'][fond]}
              # end

              months[month]['total'] += months[month]['total'] - months[prev_month]['total'] / 12
            end

            months.delete(month) if months[month]['total'] == 0
          }
          months['0'] = annual
        }
      end

      [:plan, :fact].each {|dt|
        next unless node['amount'][dt]
        node['amount'][dt].each{ |year, months|
          next if year == '_cumulative'
          next if months['0']
          
          annual = { 'total' => 0 }
          months.each_key{ |month|
            annual['total'] += months[month]['total']
          }
          months['0'] = annual
        }
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
      @kkd_info = Taxonomy.load_from_csv "db/revenue_codes.#{I18n.locale.to_s || 'uk'}.csv" if @kkd_info.nil?
      @kkd_info
    end

    def expense_codes
      @ktfk_info = Taxonomy.load_from_csv "db/expense_codes.#{I18n.locale.to_s || 'uk'}.csv" if @ktfk_info.nil?
      @ktfk_info
    end

    def self.fond_codes(locale)
      Taxonomy.load_from_csv "db/revenue_fond_codes.#{locale || I18n.locale.to_s}.csv"
    end

    def revenue_fond_codes
      @fond_info = Taxonomy.load_from_csv "db/revenue_fond_codes.#{I18n.locale.to_s || 'uk'}.csv" if @fond_info.nil?
      @fond_info
    end

    def expense_ekv_codes
      @kekv_info = Taxonomy.load_from_csv "db/expense_ekv_codes.#{I18n.locale.to_s || 'uk'}.csv" if @kekv_info.nil?
      @kekv_info
    end

    def expense_kvk_codes
      @kvk_info = Taxonomy.load_from_csv "db/expense_kvk_codes.#{I18n.locale.to_s || 'uk'}.csv" if @kvk_info.nil?
      @kvk_info
    end

    def expense_krk_codes
      file_name = "db/expense_krk_codes.#{self.area}.#{I18n.locale.to_s || 'uk'}.csv"
      @krk_info = Taxonomy.load_from_csv file_name if @krk_info.nil?
      @krk_info
    end

    protected

    def self.load_from_csv file_name
      items = {}
      CSV.foreach(file_name, {:headers => true, :col_sep => ";"}) do |row|
        items[row[0]] = { title: row[I18n.t('mongoid.taxonomy.short_title')], color: row[I18n.t('mongoid.taxonomy.color')], icon: row[I18n.t('mongoid.taxonomy.icon')], description: row[I18n.t('mongoid.taxonomy.description')] }
      end

      items
    rescue => e
      {}
    end

    private

    def generate_title
      self.title = self.class if self.title.nil?
    end

  end
