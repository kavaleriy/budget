class BudgetFile
  include Mongoid::Document

  field :author, type: String

  field :title, type: String
  field :path, type: String

  # plan, fact etc
  field :data_type

  # source data
  field :rows, :type => Hash

  belongs_to :taxonomy, autosave: true

  # calculated tree
  field :tree, :type => Hash

  field :meta_data, :type => Hash

  def self.visible_to user
    files = if user.nil?
      self.where(:author => nil)
    elsif user.has_role? :admin
      self.all
    else
      self.where(:author => nil) + BudgetFile.all.reject{|f| use.is_locked? || f.taxonomy.owner != user.town}
    end.sort_by { |f| f.author }

    files || []
  end

  def import town, table, create_new_taxonomy
    rows = table[:rows].map { |row|
      readline(row)
    }.compact.flatten.sort_by{|row| -row['amount']}


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

  def get_tree
    self.taxonomy.create_tree(self.data_type => self.rows)
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

end
