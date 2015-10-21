class ZipBudgetFile
  include Mongoid::Document

  field :title, type: String
  field :path, type: String

  has_one :rot_file, :class_name => 'BudgetFile', autosave: true, :dependent => :destroy
  has_one :rov_file, :class_name => 'BudgetFile', autosave: true, :dependent => :destroy
end
