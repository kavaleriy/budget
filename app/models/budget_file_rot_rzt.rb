class BudgetFileRotRzt < BudgetFile

  protected

  def readline row
    kkd = row['KKD'].to_s

    amount = row['SUMM'].to_i / 100
    return if amount.nil? || amount == 0


    fond = row['KKFB'].to_s
    return unless is_allowed_fond(fond)

    kod =  row['KOD'].to_s.split('.')[0]
    return if kkd.slice(0, 3) == '250' and kod == '2'

    return if %w(90010100 90010200 90010300).include?(kkd)

    kkd_a = kkd.slice(0, 1)
    kkd_b = kkd.slice(0, 2)
    kkd_cc = kkd.slice(0, 4)
    kkd_dd = kkd.slice(0, 6)

    year = row['DATA'].to_date.year.to_s.split('.')[0]

    generate_item = ->(month) do
      item = {
          '_year' => year,
          'amount' => amount,
          'fond' => fond,
          '_month' => month.to_s
      }

      [{t: 'kkd_a', key: kkd_a}, {t: 'kkd_b', key: kkd_b}, {t: 'kkd_cc', key: kkd_cc}, {t: 'kkd_dd', key: kkd_dd}, {t: 'kkd', key: kkd}].map { |v|
        item[v[:t]] = v[:key]
      }

      return item
    end

    generate_item.call(row['MONTH'].to_i)
  end

end
