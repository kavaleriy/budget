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
      {
          '_year' => row['DATA'].to_date.year.to_s,
          '_month' => row['MONTH'].to_s.split('.')[0],

          'amount' => line[:amount] / 100,
          'fond' => line[:fond],

          'kvk' => "#{row['KVK'].to_s}:#{row['KRK'].to_s}",
          'kekv' => row['KEKV'].to_s,
          # 'ktfk_aaa' => row['KTFK'].to_s.slice(0, 3),
          'ktfk' => row['KTFK'].to_s,
          # 'krk' => row['KRK'].to_s,
      }
    }.reject {|c| c.nil? || c['amount'] == 0 }
  end

end
