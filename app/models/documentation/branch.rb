class Documentation::Branch
  include Mongoid::Document
  field :title, type: String

  def self.columns
    self.fields.collect{|c| c[1]}
  end

  has_many :document_category, class_name: 'Documentation::Document'
end
