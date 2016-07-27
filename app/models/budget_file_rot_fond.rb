class BudgetFileRotFond < BudgetFileRot

  protected

  def readline row
    kkd = row['Код'].to_s.split('.')[0] || row['kkd'].to_s.split('.')[0]
    return if kkd == ''

    amount1 = row[I18n.t('mongoid.taxonomy_rot_fond.gen_fund')].to_i
    amount2 = row[I18n.t('mongoid.taxonomy_rot_fond.spec_fund')].to_i

    [
        { :amount => amount1, :fond => '1' },
        { :amount => amount2, :fond => '7' },
    ].map { |line|
      next if line[:amount].to_i == 0

      fond = line[:fond]
      next unless is_allowed_fond(fond)

      amount = line[:amount]

      item = {
          'amount' => amount,
          'fond' => fond,
      }

      %w(_year _qt _month).each{ |key|
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
