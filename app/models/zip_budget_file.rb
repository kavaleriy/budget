class ZipBudgetFile
  include Mongoid::Document

  field :title, type: String
  field :path, type: String
end
