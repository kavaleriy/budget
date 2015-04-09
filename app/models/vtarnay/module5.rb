class Vtarnay::Module5
  include Mongoid::Document

  field :title, type: String
  field :path, type: String

  # source data
  field :rows, :type => Hash

  def import table
    rows = {}

    table[:rows].each{|row|
      if rows[row['group']].nil?
        rows[row['group']] = {}
      end
      if rows[row['group']][row['indicator']].nil?
        rows[row['group']][row['indicator']] = {}
      end
      year = row['year'].to_i
      rows[row['group']][row['indicator']][year] = {}
      rows[row['group']][row['indicator']][year]['comment'] = row['comment']
      rows[row['group']][row['indicator']][year]['value'] = row['value']
    }

    self.rows = rows
  end
end
