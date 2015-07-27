module ColumnsList
  extend ActiveSupport::Concern

  def columns
    self.fields.collect{|c| c[1]}
  end

end