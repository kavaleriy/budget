class BudgetFileRovFond < BudgetFile

  protected

  def get_taxonomy owner, columns
    TaxonomyRov.get_taxonomy(owner)
  end

  def readline row
    ktfk = row['ktfk'].to_s.split('.')[0]

    ktfk_aaa = ktfk.slice(0, ktfk.length - 3).ljust(3, '0')
    ktfk_aaa = '800' if ktfk_aaa == '810'
    ktfk_aaa = '900' if ktfk_aaa == '910'

    kvk = row['kvk'].to_s
    krk = row['krk'].to_s
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
            'fond' => line[:fond],

            'amount' => line[:amount] / 100,
            'kvk' => kvk,
            'krk' => krk,
            'kekv' => kekv,
            'ktfk' => ktfk,
            'ktfk_aaa' => ktfk_aaa,
        }

      %w(_year _month).each{ |key|
        item[key] = row[key].to_i unless row[key].nil?
      }

      item
    }.compact.reject {|c| c['amount'] == 0 }
  end

  private

  def set_data_type
    self.data_type = :plan if self.data_type.nil?
  end

end
