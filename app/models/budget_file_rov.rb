class BudgetFileRov < BudgetFile

  protected

  def readline row
    month = row['MONTH'].to_s.split('.')[0]
    return if month == '0' # add annual amount manually
    
    ktfk = row['KTFK'].to_i.to_s.gsub(/^0*/, "")

    amount = row['SUMM'].to_i
    return if amount.nil? || amount == 0

    fond = row['KKFN'].to_s.split('.')[0]
    # return unless is_allowed_fond(fond)

    kekv = row['KEKV'].to_s.split('.')[0]
    # return if is_grouped_kekv kekv

    kod =  row['KOD'].to_s.split('.')[0]
    return if fond != '1' and kod == '1'


    ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
    ktfk_aaa = '80' if ktfk_aaa == '81'
    ktfk_aaa = '90' if ktfk_aaa == '91'
    
    [0, month].map { |_month|
      {
        '_year' => row['DATA'].to_date.year.to_s.split('.')[0],
        '_month' => _month,

        'fond' => fond,

        'amount' => amount / 100,
        'ktfk' => ktfk,
        'ktfk_aaa' => ktfk_aaa,
        'kvk' => row['KVK'].to_s.split('.')[0],
        'kekv' => kekv,
        'krk' => row['KRK'].to_s.split('.')[0],
      }
    }
  end

end
