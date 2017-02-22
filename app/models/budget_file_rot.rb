class BudgetFileRot < BudgetFile

  protected

  def readline row
    kkd = row['KKD'].to_s

    amount = row['SUMM'].to_i
    return if amount.nil? || amount == 0

    fond = row['KKFN'].to_s.split('.')[0]
    return unless is_allowed_fond(fond)

    kod =  row['KOD'].to_s.split('.')[0]
    return if ['25010100','25010300','20510400'].include?(kkd) and kod == '2'


    item = {
        '_year' => row['DATA'].to_date.year.to_s.split('.')[0],
        '_month' => row['MONTH'].to_s.split('.')[0],
        'fond' => fond,
        'amount' => amount / 100,
    }

    kkd_a = kkd.slice(0, 1)
    kkd_b = kkd.slice(0, 2)
    kkd_cc = kkd.slice(0, 4)
    kkd_dd = kkd.slice(0, 6)

    [{t: 'kkd_a', key: kkd_a}, {t: 'kkd_b', key: kkd_b}, {t: 'kkd_cc', key: kkd_cc}, {t: 'kkd_dd', key: kkd_dd}, {t: 'kkd', key: kkd}].map { |v|
      item[v[:t]] = v[:key]
    }

    item unless item.nil?
  end
end
