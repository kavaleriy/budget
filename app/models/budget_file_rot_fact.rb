class BudgetFileRotFact < BudgetFile

  protected

  def readline row
    amount = row['SUMM'].to_i
    return if amount.nil? || amount == 0

    kkd = row['KKD'].to_s

    item = {
        '_year' => row['DATA'].to_date.year.to_s,
        '_month' => row['MONTH'].to_s.split('.')[0],
        'fond' => row['KKFN'].to_s,
        'amount' => amount / 100,
    }
    [{t: 'kkd_a', key: kkd.slice(0, 1)}, {t: 'kkd_b', key: kkd.slice(0, 2)}, {t: 'kkd_cc', key: kkd.slice(0, 4)}, {t: 'kkd_dd', key: kkd.slice(0, 6)}, {t: 'kkd', key: kkd}].map { |v|
      item[v[:t]] = v[:key]
    }

    item if (item['kkd_dd'] =~ /00$/) == nil
  end

end
