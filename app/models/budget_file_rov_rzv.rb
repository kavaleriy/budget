class BudgetFileRovRzv < BudgetFile

  protected

  def readline row
    ktfk = row['KTFK'].to_i.to_s.gsub(/^0*/, "")

    amount = row['SUMM'].to_i / 100
    return if amount.nil? || amount == 0

    fond = row['KKFB'].to_s.split('.')[0]
    # return unless is_allowed_fond(fond)

    kekv = row['KEKV'].to_s.split('.')[0]
    return if is_grouped_kekv kekv

    ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
    ktfk_aaa = '80' if ktfk_aaa == '81'
    ktfk_aaa = '90' if ktfk_aaa == '91'


    generate_item = ->(month) do
      {
          '_year' => row['DATA'].to_date.year.to_s.split('.')[0],
          '_month' => month,

          'fond' => fond,

          'amount' => amount,
          'ktfk' => ktfk,
          'ktfk_aaa' => ktfk_aaa,
          'kvk' => row['KVK'].to_s.split('.')[0],
          'kekv' => kekv,
          'krk' => row['KRK'].to_s.split('.')[0],
      }
    end

    generate_item.call(row['MONTH'].to_i)
  end

end
