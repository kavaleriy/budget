class BudgetFile
  include Mongoid::Document

  field :author, type: String

  field :title, type: String
  field :path, type: String

  # source data
  field :rows, :type => Hash

  # list of taxonomies for tree levels
  belongs_to :taxonomy, autosave: true

  # calculated tree
  field :tree, :type => Hash

  field :meta_data, :type => Hash


  def import town, table, year
    self.taxonomy = get_taxonomy town, table[:cols]

    rows = table[:rows].map { |row|
      self.taxonomy.readline(row)
    }.reject { |c| c.nil? }.flatten

    months = {}
    rows.each { |row|
      month = row['_month'] || '0'
      months[month] = [] if months[month].nil?
      months[month] << row.reject{|k| k == '_month'}
    }

    self.rows = { year => months}

    months.keys.each do |month|
      months[month].each do |row|
        row.keys.reject{|key| key == 'amount'}.each { |key|
          self.taxonomy.explain(key, row[key])
        }
      end
    end
  end

  def get_tree year, month
    self.taxonomy.create_tree self.rows, year, month
  end

  protected

  def get_taxonomy owner, columns
    Taxonomy.get_taxonomy(owner, columns)
  end


end
