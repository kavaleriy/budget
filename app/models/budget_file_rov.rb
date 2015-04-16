class BudgetFileRov < BudgetFile

  protected

  def get_taxonomy owner, columns
    TaxonomyRov.get_taxonomy(owner)
  end

  def readline row
    amount = row['SUMM'].to_i
    return if amount.nil? || amount == 0

    ktfk = row['KTFK'].to_s

    ktfk_aaa = ktfk.slice(0, ktfk.length - 3)
    ktfk_aaa = '80' if ktfk_aaa == '81'
    ktfk_aaa = '90' if ktfk_aaa == '91'

    {
        '_year' => row['DATA'].to_date.year.to_s,
        '_month' => row['MONTH'].to_s.split('.')[0],
        'amount' => amount / 100,
        'ktfk' => ktfk,
        'ktfk_aaa' => ktfk_aaa,
        'fond' => row['KKFN'].to_s,
        'kvk' => row['KVK'].to_s,
        'kekv' => row['KEKV'].to_s,
        'krk' => row['KRK'].to_s,
    }
  end

end
