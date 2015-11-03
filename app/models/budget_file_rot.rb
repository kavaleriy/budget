class BudgetFileRot < BudgetFile

  protected

  def readline row

    amount = row['SUMM'].to_i
    return if amount.nil? || amount == 0

    kkd = row['KKD'].to_s

    line = {
        '_year' => row['DATA'].to_date.year.to_s.split('.')[0],
        '_month' => row['MONTH'].to_s.split('.')[0],
        'fond' => row['KKFN'].to_s.split('.')[0],
        'amount' => amount / 100,
    }
    [{t: 'kkd_a', key: kkd.slice(0, 1)}, {t: 'kkd_b', key: kkd.slice(0, 2)}, {t: 'kkd_cc', key: kkd.slice(0, 4)}, {t: 'kkd_dd', key: kkd.slice(0, 6)}, {t: 'kkd', key: kkd},
     {t: '_kkd_a', key: kkd.slice(0, 1)}, {t: '_kkd_b', key: kkd.slice(1, 1)}, {t: '_kkd_cc', key: kkd.slice(2, 2)}, {t: '_kkd_dd', key: kkd.slice(4, 2)}, {t: '_kkd', key: kkd.slice(6, 2)}].map { |v|
      line[v[:t]] = v[:key]
    }

    line if (line['kkd_dd'] =~ /00$/) == nil
  end
end
