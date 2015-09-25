class BudgetFileRov < BudgetFile

  protected

  def readline row

    amount = row['SUMM'].to_i
    return if amount.nil? || amount == 0

    ktfk = row['KTFK'].to_i.to_s.gsub(/^0*/, "")

    ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
    ktfk_aaa = '80' if ktfk_aaa == '81'
    ktfk_aaa = '90' if ktfk_aaa == '91'

    {
        '_year' => row['DATA'].to_date.year.to_s.split('.')[0],
        '_month' => row['MONTH'].to_s.split('.')[0],

        'fond' => row['KKFN'].to_s.split('.')[0],

        'amount' => amount / 100,
        'ktfk' => ktfk,
        'ktfk_aaa' => ktfk_aaa,
        'kvk' => row['KVK'].to_s.split('.')[0],
        'kekv' => row['KEKV'].to_s.split('.')[0],
        'krk' => row['KRK'].to_s.split('.')[0],
    }
  end

end
