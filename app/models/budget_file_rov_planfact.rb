class BudgetFileRovPlanfact < BudgetFile

  protected

  def get_taxonomy owner, columns
    TaxonomyRov.get_taxonomy(owner)
  end

  def readline row
    amount_plan = row['План на рік з урахуванням змін'].to_i
    amount_fact = row['Касові видатки за вказаний період'].to_i

    ktfk = row['Код'].to_s.split('.')[0].gsub(/^0*/, "")
    return if ktfk.to_i == 0

    ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
    ktfk_aaa = '80' if ktfk_aaa == '81'
    ktfk_aaa = '90' if ktfk_aaa == '91'

    kekv = row['kekv'].to_s.split('.')[0]
    kvk = row['kvk'].to_s.split('.')[0]

    [
        { :amount => amount_plan, :amount_type => :plan },
        { :amount => amount_fact, :amount_type => :fact },
    ].map { |line|

      item = {
          'amount' => line[:amount],

          'ktfk' => ktfk,
          'ktfk_aaa' => ktfk_aaa,

          'kvk' => kvk,
          'kekv' => kekv,

          '_amount_type' => line[:amount_type]
      }

      %w(_year _month).each{ |key|
        item[key] = row[key].to_i unless row[key].nil?
      }

      item
    }.reject {|c| c.nil? || c['amount'] == 0 }
  end

end
