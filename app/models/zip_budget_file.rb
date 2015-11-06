class ZipBudgetFile
  include Mongoid::Document

  field :title, type: String
  field :path, type: String

  has_many :rot_files, :class_name => 'BudgetFile', autosave: true, :dependent => :destroy
  has_many :rov_files, :class_name => 'BudgetFile', autosave: true, :dependent => :destroy
end
