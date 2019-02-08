class Documentation::Link
  include Documentation
  include Mongoid::Document

  scope :get_links_by_town, -> (town) { where(:town => town) }
  scope :with_category, -> { where(:link_category_id.ne => nil) }

  belongs_to :link_category, class_name: 'Documentation::LinkCategory', autosave: true
  belongs_to :town, class_name: '::Town'
  field :title, type: String
  field :value, type: String
  field :description, type: String
  field :yearFrom, type: Integer
  field :yearTo, type: Integer

  def self.get_hash_links_by_town(town)
    links = self.get_links_by_town(town).with_category
    res = []
    links.each do |link|
      # TODO: maybe change links query
      # today category_title not show on site
      # cat_title = link.link_category.title unless link.link_category.nil?
      tmp_hash = {
        # category_title: cat_title,
        href: link.value,
        title: link.title,
        description: link.description
      }
      res << tmp_hash
    end
    res
  end
end