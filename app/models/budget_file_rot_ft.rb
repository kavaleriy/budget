class BudgetFileRotFt < BudgetFile

  protected

  def readline row
    fond = row['GR'].to_s.split('.')[0]
    return unless is_allowed_fond(fond)

    kkd = row['KOD'].to_s

    return unless kkd.length == 8
    return if %w(90010100 90010200 90010300).include?(kkd)


    kkd_a = kkd.slice(0, 1)
    kkd_b = kkd.slice(0, 2)
    kkd_cc = kkd.slice(0, 4)
    kkd_dd = kkd.slice(0, 6)


    [
        { :amount => row['T020'].to_f },
    ].map do |line|
      next if line[:amount].to_i == 0

      item = {
          'amount' => line[:amount] / 100,
          'fond' => fond.to_i,
      }

      dt = row['DT'].to_date
      item['_year'] = dt.year.to_s
      item['_month'] = dt.month.to_s

      [{t: 'kkd_a', key: kkd_a}, {t: 'kkd_b', key: kkd_b}, {t: 'kkd_cc', key: kkd_cc}, {t: 'kkd_dd', key: kkd_dd}, {t: 'kkd', key: kkd}].map { |v|
        item[v[:t]] = v[:key]
      }

      item
    # end.reject {|c| c.nil? || (c['kkd_dd'] =~ /00$/) != nil}
    end.reject {|c| c.nil?}
  end

end
