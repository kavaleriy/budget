class BudgetFile
  include Mongoid::Document

  field :author, type: String

  field :title, type: String
  field :path, type: String

  field :data_type, type: Symbol # e.g :plan or :fact

  # source data
  field :rows, :type => Hash

  # list of taxonomies for tree levels
  belongs_to :taxonomy, autosave: true

  # calculated tree
  field :tree, :type => Hash

  field :meta_data, :type => Hash


  def import town, table
    self.taxonomy = get_taxonomy town, table[:cols]

    rows = table[:rows].map { |row|
      self.taxonomy.readline(row)
    }.reject { |c| c.nil? }.flatten.sort_by{|row| -row['amount']}

    years = {}
    rows.each { |row|

      year = row['_year'] || Date.current.year.to_s

      month = row['_month'] || '0'

      years[year] = {} if years[year].nil?

      years[year][month] = [] if years[year][month].nil?
      years[year][month] << row.reject{|k| k.start_with?('_')}
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
    self.taxonomy.create_tree self.rows
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

  protected

  def get_taxonomy owner, columns
    Taxonomy.get_taxonomy(owner, columns)
  end


end
