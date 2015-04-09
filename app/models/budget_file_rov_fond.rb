class BudgetFileRovFond < BudgetFileRov

  protected

  def get_taxonomy owner, columns
    TaxonomyRov.get_taxonomy(owner)
  end

  def readline row
    amount1 = row[I18n.t('activerecord.taxonomy_rov_fond.gen_fund')].to_i
    amount2 = row[I18n.t('activerecord.taxonomy_rov_fond.spec_fund')].to_i

    [
        { :amount => amount1,
          :fond => I18n.t('activerecord.taxonomy_rov_fond.gen_fund') },
        { :amount => amount2,
          :fond => I18n.t('activerecord.taxonomy_rov_fond.spec_fund')
        },
    ].map { |line|
      ktfk = row['ktfk'].to_s
      item =
        {
            'amount' => line[:amount] / 100,
            'fond' => line[:fond],

            'kvk' => "#{row['kvk'].to_s}:#{row['krk'].to_s}",
            'kekv' => row['kekv'].to_s || '-',
            'ktfk' => ktfk,
            'ktfk_aaa' => ktfk.slice(0, ktfk.length - 3),
            'krk' => row['KRK'].to_s,
        }

      %w(_year _month).each{ |key|
        item[key] = row[key].to_i unless row[key].nil?
      }

      item
    }.reject {|c| c.nil? || c['amount'] == 0 }
  end

end
