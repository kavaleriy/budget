class BudgetFileRovFond < BudgetFile

  protected

  def readline row
    ktfk = row['Код'].to_s.split('.')[0].gsub(/^0*/, "")

    ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
    ktfk_aaa = '80' if ktfk_aaa == '81'
    ktfk_aaa = '90' if ktfk_aaa == '91'

    kvk = row['kvk'].to_s.split('.')[0]
    krk = row['krk'].to_s.split('.')[0]
    kekv = row['kekv'].to_s.split('.')[0]

    amount1 = row[I18n.t('mongoid.taxonomy_rov_fond.gen_fund')].to_i
    amount2 = row[I18n.t('mongoid.taxonomy_rov_fond.spec_fund')].to_i

    [
        { :amount => amount1, :fond => '1' },
        { :amount => amount2, :fond => '7' },
    ].map { |line|
      next if line[:amount].to_i == 0

      item =
        {
            'fond' => line[:fond],

            'amount' => line[:amount],
            'kvk' => kvk,
            'krk' => krk,
            'kekv' => kekv,

            'ktfk' => ktfk,
            'ktfk_aaa' => ktfk_aaa,
        }

      %w(_year _qt _month).each{ |key|
        item[key] = row[key].to_i unless row[key].nil?
      }

      item
    }.compact.reject {|c| c['amount'] == 0 }
  end

end
