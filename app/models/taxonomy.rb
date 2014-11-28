class Taxonomy
  include Mongoid::Document

  field :name, type: String
  field :columns, type: Hash

  field :explanation, :type => Hash

  belongs_to :budget_files

  def self.get_taxonomy(name, columns)
    cols = {}
    columns.each { |col|
      cols[col] = { :title => "Рівень: #{col}" }
    }

    Taxonomy.where(:name => name).last || Taxonomy.create(
        :name => name,
        :columns => columns
    )
  end
end
