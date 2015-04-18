class BudgetFileRov < BudgetFile

  protected

  def get_taxonomy owner, columns
    TaxonomyRov.get_taxonomy(owner)
  end

  def readline row
    amount = row['SUMM'].to_i
    return if amount.nil? || amount == 0

    ktfk = row['KTFK'].to_s

    ktfk_aaa = ktfk.slice(0, ktfk.length - 3).ljust(3, '0')
    ktfk_aaa = '800' if ktfk_aaa == '810'
    ktfk_aaa = '900' if ktfk_aaa == '910'

    {
        '_year' => row['DATA'].to_date.year.to_s,
        '_month' => row['MONTH'].to_s.split('.')[0],
        '_fond' => row['KKFN'].to_s,

        'amount' => amount / 100,
        'ktfk' => ktfk,
        'ktfk_aaa' => ktfk_aaa,
        'kvk' => row['KVK'].to_s,
        'kekv' => row['KEKV'].to_s,
        'krk' => row['KRK'].to_s,
    }
  end

  private

  def set_data_type
    self.data_type = :plan if self.data_type.nil?
  end

end
