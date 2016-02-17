class Documentation::Link
  include Mongoid::Document

  belongs_to :link_category, class_name: 'Documentation::LinkCategory', autosave: true
  belongs_to :town, class_name: '::Town'
  field :title, type: String
  field :value, type: String
  field :yearFrom, type: Integer
  field :yearTo, type: Integer


  def self.get_link_by_town (town)

    if town.id == 'test'
      Documentation::Link.all.where(:town => nil)
    else
      Documentation::Link.all.where(:town => town)
    end

  end
end