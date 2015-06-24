class Town
  include Mongoid::Document
  field :title, type: String

  has_many :document_category, class_name: 'Documentation::Category'

  def self.columns
    self.fields.collect{|c| c[1]}
  end
end
