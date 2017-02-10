class BudgetFileRov < BudgetFile

  protected

  def readline row
    ktfk = row['KTFK'].to_i.to_s.gsub(/^0*/, "")

    amount = row['SUMM'].to_i
    return if amount.nil? || amount == 0

    fond = row['KKFN'].to_s.split('.')[0]
    # return unless is_allowed_fond(fond)

    kekv = row['KEKV'].to_s.split('.')[0]
    return if is_grouped_kekv kekv

    kod =  row['KOD'].to_s.split('.')[0]
    return if fond != '1' and kod == '1'

    # calc special fond annual amount
    month = row['MONTH'].to_s.split('.')[0]
    return if fond == '7' and month == '0' and ktfk.blank? # since 2017 this patch is outdated
    months = [ month ]
    months << '0' if fond == '7' # add annual amount manually


    months.map do |mon|
      item = if ktfk.blank?
               kpk = row['KPK'].to_s.ljust(7, '0')
               # Головний розпорядник (код відомчої класифікації видатків та кредитування місцевого бюджету)
               kpk_aa = kpk.slice(0, 2)
               # Відповідальний виконавець бюджетної програми у системі головного розпорядника.
               kpk_b = kpk.slice(2, 1)
               # Номер програми
               kpk_ccc = kpk.slice(3, 3)
               # Номер підпрограми
               kpk_d = kpk.slice(6, 1)

               {
                   'kpk_aa' => kpk_aa,
                   'kpk_b' => kpk_b,
                   'kpk_cccd' => kpk_ccc + kpk_d,
                   'kpk_d' => kpk_d,
               }
             else
               ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
               ktfk_aaa = '80' if ktfk_aaa == '81'
               ktfk_aaa = '90' if ktfk_aaa == '91'

               {
                   'ktfk' => ktfk,
                   'ktfk_aaa' => ktfk_aaa
               }
             end



      item.merge({
        '_year' => row['DATA'].to_date.year.to_s.split('.')[0],
        '_month' => mon,

        'fond' => fond,

        'amount' => amount / 100,
        'kvk' => row['KVK'].to_s.split('.')[0],
        'kekv' => kekv,
        'krk' => row['KRK'].to_s.split('.')[0],
      })
    end
  end

end
