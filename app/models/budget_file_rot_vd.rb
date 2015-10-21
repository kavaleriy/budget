class BudgetFileRotVd < BudgetFile

  protected

  def readline row
    kkd = row['KOD'].to_s

    return unless kkd.length == 8
    return if %w(90010100 90010200 90010300).include?(kkd)

    kkd_a = kkd.slice(0, 1)
    kkd_b = kkd.slice(0, 2)
    kkd_cc = kkd.slice(0, 4)
    kkd_dd = kkd.slice(0, 6)

    [
        { :amount => row['N1'].to_i, :fond => 1 },
        { :amount => row['N4'].to_i, :fond => 7 },
    ].map do |line|
      next if line[:amount].to_i == 0

      item = {
          'amount' => line[:amount],
          'fond' => line[:fond],
      }

      %w(_year _month).each{ |key|
        item[key] = row[key].to_i unless row[key].nil?
      }

      [{t: 'kkd_a', key: kkd_a}, {t: 'kkd_b', key: kkd_b}, {t: 'kkd_cc', key: kkd_cc}, {t: 'kkd_dd', key: kkd_dd}, {t: 'kkd_ee', key: kkd}].map { |v|
        item[v[:t]] = v[:key]
      }

      item
    end.reject {|c| c.nil? || (c['kkd_dd'] =~ /00$/) != nil}
  end

end
