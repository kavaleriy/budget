class BudgetFileRovFact < BudgetFile

  protected

  def get_taxonomy owner, columns
    TaxonomyRovFact.get_taxonomy(owner)
  end

  def readline row
    amount = row['SUMM'].to_i
    return if amount.nil? || amount == 0

    {
        '_year' => row['DATA'].to_date.year.to_s,
        '_month' => row['MONTH'].to_s.split('.')[0],
        'amount' => amount / 100,
        'fond' => row['KKFN'].to_s,
        'kvk' => "#{row['KVK'].to_s}:#{row['KRK'].to_s}",
        'kekv' => row['KEKV'].to_s,
        # 'ktfk_aaa' => row['KTFK'].to_s.slice(0, 3),
        'ktfk' => row['KTFK'].to_s,
        # 'krk' => row['KRK'].to_s,
    }
  end

end
