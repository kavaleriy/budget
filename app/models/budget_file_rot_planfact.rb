class BudgetFileRotPlanfact < BudgetFile

  protected

  def readline row
    amount_plan = row['План'].to_i
    amount_fact = row['Факт'].to_i

    kkd = row['Код'].to_s.gsub(/\s+/, "").split('.')[0]
    return if kkd.to_i == 0

    fond = row['Фонд'].to_s.split('.')[0]
    return unless is_allowed_fond(fond)

    [
        { :amount => amount_plan, :amount_type => :plan },
        { :amount => amount_fact, :amount_type => :fact },
    ].map { |line|
      next if line[:amount].to_i == 0

      item = {
          'amount' => line[:amount],

          '_amount_type' => line[:amount_type],

          'fond' => fond
      }

      %w(_year _month).each{ |key|
        item[key] = row[key].to_i unless row[key].nil?
      }

      kkd_a = kkd.slice(0, 1)
      kkd_b = kkd.slice(0, 2)
      kkd_cc = kkd.slice(0, 4)
      kkd_dd = kkd.slice(0, 6)
      [{t: 'kkd_a', key: kkd_a}, {t: 'kkd_b', key: kkd_b}, {t: 'kkd_cc', key: kkd_cc}, {t: 'kkd_dd', key: kkd_dd}, {t: 'kkd', key: kkd}].map { |v|
        item[v[:t]] = v[:key]
      }

      item
    }.reject {|c| c.nil? || c['amount'] == 0}
  end

end
