class BudgetFileRot < BudgetFile

  before_save :default_values

  def default_values
    self.type = 'plan'
  end

  protected

  def get_taxonomy owner, columns
    TaxonomyRot.get_taxonomy(owner)
  end

  def readline row

    amount = row['SUMM'].to_i
    return if amount.nil? || amount == 0

    kkd = row['KKD'].to_s

    line = {
        '_year' => row['DATA'].to_date.year.to_s,
        '_month' => row['MONTH'].to_s.split('.')[0],
        'fond' => row['KKFN'].to_s,
        'amount' => amount / 100,
    }
    [{t: 'kkd_a', key: kkd.slice(0, 1)}, {t: 'kkd_bb', key: kkd.slice(0, 3)}, {t: 'kkd_cc', key: kkd.slice(0, 5)}, {t: 'kkd', key: kkd.slice(0, 8)}].map { |v|
      line[v[:t]] = v[:key]
    }

    line
  end

  private

  def set_data_type
    self.data_type = :plan if self.data_type.nil?
  end

end
