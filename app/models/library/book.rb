class Library::Book
  include Mongoid::Document
  field :title, type: String
  # field :year_published, type: String
  #field :link, type: String
  field :description, type: String

end
