class BudgetFileRovFact < BudgetFileRov

  def import town, table
    self.taxonomy = get_taxonomy town, table[:cols]

    rows = table[:rows].map { |row|
      readline(row)
    }.reject { |c| c.nil? }

    self.rows = {'rows' => rows}

    # years = {}
    # rows.each { |row|
    #
    #   year = row['_year'] || Date.current.year.to_s
    #
    #   month = row['_month'] || '0'
    #
    #   years[year] = {} if years[year].nil?
    #
    #   years[year][month] = [] if years[year][month].nil?
    #   years[year][month] << row.reject{|k| k.start_with?('_')}
    # }
    #
    # self.rows = years
    #
    # years.keys.each do |year|
    #   years[year].keys.each do |month|
    #     years[year][month].each do |row|
    #       row.keys.reject{|key| key == 'amount'}.each { |key|
    #         self.taxonomy.explain(key, row[key])
    #       }
    #     end
    #   end
    # end
  end

  protected

  def get_taxonomy owner, columns
    TaxonomyRovFact.get_taxonomy(owner)
  end

  def readline row

    amount = {}

    for i in 1..12
      amount[i] = row["N#{i}"]
    end

    line = {
        'amount' => amount,
    }

    row.keys.reject{|k| k.start_with?('N') }.each {|r|
      val = row[r].to_s.split('.')[0]
      line[r] = val
    }

    line
  end

end
