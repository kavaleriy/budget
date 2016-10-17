class FzBudgetFile
  include Mongoid::Document

  field :title, type: String
  field :path, type: String

  has_many :rot_file, :class_name => 'BudgetFile', autosave: true, :dependent => :destroy
  has_many :rov_file, :class_name => 'BudgetFile', autosave: true, :dependent => :destroy
end
