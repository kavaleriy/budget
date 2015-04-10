class Vtarnay::Module5
  include Mongoid::Document

  field :author, type: String
  field :title, type: String
  field :path, type: String
  field :town, type: String

  # source data
  field :rows, :type => Hash

  def import table
    rows = {}

    table[:rows].each_with_index{|row, i|
      rows[i] = row
    }

    self.rows = rows
  end

end
