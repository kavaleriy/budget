class BudgetFileRovFond < BudgetFileRov

  protected

  def get_taxonomy owner, columns
    TaxonomyRov.get_taxonomy(owner)
  end

  def readline row
    ktfk = row['ktfk'].to_s.split('.')[0]
    ktfk_aaa = ktfk.slice(0, ktfk.length - 3)
    kekv = row['kekv'].to_s.split('.')[0]

    amount1 = row[I18n.t('activerecord.taxonomy_rov_fond.gen_fund')].to_i
    amount2 = row[I18n.t('activerecord.taxonomy_rov_fond.spec_fund')].to_i

    [
        { :amount => amount1, :fond => '1' },
        { :amount => amount2, :fond => '7' },
    ].map { |line|
      next if line[:amount].nil?

      item =
        {
            'amount' => line[:amount] / 100,
            'fond' => line[:fond],

            # 'kvk' => "#{row['kvk'].to_s}:#{row['krk'].to_s}",
            'kekv' => kekv,
            'ktfk' => ktfk,
            'ktfk_aaa' => ktfk_aaa,
            # 'krk' => row['KRK'].to_s,
        }

      %w(_year _month).each{ |key|
        item[key] = row[key].to_i unless row[key].nil?
      }

      item
    }.compact.reject {|c| c['amount'] == 0 }
  end

end
