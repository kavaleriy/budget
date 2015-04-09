class TaxonomyFree < Taxonomy

  field :columns, type: Hash

  def self.get_taxonomy(owner, columns)
    cols = {}

    columns.each { |col|
      cols[col] = { :level => cols.length + 1, :title => col } unless col == columns[columns.length - 1]
    }

    self.where(:owner => owner, :columns => columns).last || self.create(
        :owner => owner,
        :columns => cols,
    )
  end

end
