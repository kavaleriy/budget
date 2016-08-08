class BudgetFile
  include Mongoid::Document

  field :author, type: String

  belongs_to :author_model,class_name: 'User'
  field :title, type: String
  field :name, type: String
  field :path, type: String

  # plan, fact etc
  field :data_type
  before_save :symbolize_data_type
  def symbolize_data_type
    self.data_type = self.data_type.to_sym
  end

  field :cumulative_sum, :type => Boolean

  # source data
  field :rows, :type => Hash

  belongs_to :taxonomy, autosave: true
  belongs_to :zip_budget_file, autosave: true
  belongs_to :fz_budget_file, autosave: true

  # calculated tree
  field :tree, :type => Hash

  field :meta_data, :type => Hash


  def is_allowed_fond fond
    fond.nil? or %w(1 2 7).include? fond
  end

  def is_grouped_kekv kekv
    # https://e.mail.ru/message/14485687760000000480/?fromsearch=search&tab-time=1469948026&q_query=2270&withattachs=Y&from_suggest=0&from_search=0&offset=6
    kekv.nil? or %w(2000 2100 2110 2200 2270 2280 2400 2600 2700 3000 3100 3120 3130 3140 3200 4100 4110 4200 9102).include?(kekv)
  end

  def self.visible_to user
    files = if user.nil?
      self.where(:author => nil)
    elsif user.has_role? :admin
      self.all
    else
      self.where(author: user.email)
      # self.or({author: nil}, {author: user.email})
    end

    files || []
  end

  def import table

    rows = table.map { |row|
      readline(row)
    }.compact.flatten.reject{|row| row['amount'] == 0}.sort_by{|row| -row['amount']}

    # tree = {}
    # table[:rows].each { |row|
    #   parsed_rows = readline(row)
    #   parsed_rows.map{ |line|
    #     taxonomy.add_leaf(tree, line)
    #   } unless parsed_rows.nil?
    # }
    #
    # rows = taxonomy.extract_rows(tree).compact.flatten.reject{|row| row['amount'] == 0}.sort_by{|row| -row['amount']}

    years = {}
    rows.each { |row|

      year = row['_year'] || Date.current.year.to_s

      month = row['_month'] || '0'

      years[year] = {} if years[year].nil?

      years[year][month] = [] if years[year][month].nil?
      years[year][month] << row.reject{|k| k.in?(%w(_year _month))}
    }

    self.rows = years

    years.keys.each do |year|
      years[year].keys.each do |month|
        years[year][month].each do |row|
          row.keys.reject{|key| key == 'amount'}.each { |key|
            self.taxonomy.explain(key, row[key])
          }
        end
      end
    end

  end


  def get_rows
    rows = self.rows

    amount_type = self.data_type || :plan
    is_cumulative_sum = (self.cumulative_sum == true)

    rows.each{|year, months| months.each{ |month, items| items.each { |item|
      item['_amount_type'] ||= amount_type
      item['_cumulative'] = is_cumulative_sum
    } } }

    rows
  end

  def get_tree levels
    rows = get_rows
    self.taxonomy.create_tree(rows, [], levels)
  end

  def get_subtree level, key, filter
    subrows = {}
    self.rows.keys.each {|year|
      subrows[year] = {} if subrows[year].nil?
      self.rows[year].keys.each { |month|
        subrows[year][month] = [] if subrows[year][month].nil?
        self.rows[year][month].each { |row|
          subrows[year][month] << row.reject{|k, v| filter.include?(k) } if row[level] == key
        }
      }
    }
    self.taxonomy.create_tree subrows, filter
  end

  def get_range
    range = {}

    self.rows.keys.each {|year|
      self.rows[year].keys.each { |month|
        range[year] = {} if range[year].nil?
        self.rows[year][month].each { |row|
          range[year][month] = month if range[year][month].nil?
        }
      }
    }

    range.map { |k,v| {k => v.keys.sort_by { |kk| kk.to_i } } }
  end

  def self.get_budget_file_for_example
    # this function return model which have valid filename path
    # first of all take first model_count model
    # if someone model have valid filename path return him
    # if no one model don't have valid filename path return first Budget_file
    model_count = 20
    res_model = self.first

    models = self.asc(:title).limit(model_count).to_a
    models.each do |model|
    if File.exist?(model.path.to_s)
      res_model = model
      end
    end
    res_model
  end
end