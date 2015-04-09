class BudgetFileRov < BudgetFile

  protected

  def get_taxonomy owner, columns
    TaxonomyRov.get_taxonomy(owner)
  end

  def readline row
    amount = row['SUMM'].to_i
    return if amount.nil? || amount == 0

    ktfk = row['KTFK'].to_s
    {
        '_year' => row['DATA'].to_date.year.to_s,
        '_month' => row['MONTH'].to_s.split('.')[0],
        'amount' => amount / 100,
        'fond' => row['KKFN'].to_s,
        'kvk' => row['KVK'].to_s,
        'kekv' => row['KEKV'].to_s,
        'ktfk' => ktfk,
        'ktfk_aaa' => ktfk.slice(0, ktfk.length - 3),
        'krk' => row['KRK'].to_s,
    }
  end

end
