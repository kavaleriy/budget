class BudgetFileRovFact < BudgetFile

  protected

  def get_taxonomy owner, columns
    TaxonomyRov.get_taxonomy(owner)
  end

  def readline row
    ktfk = row['KFK'].to_s.gsub(/^0*/, "")

    ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
    ktfk_aaa = '80' if ktfk_aaa == '81'
    ktfk_aaa = '90' if ktfk_aaa == '91'

    kvk = row['KVK'].to_s
    kekv = row['KOD'].to_s

    amount_year = 0
    lines = (1..12).map{|m|
      amount = (row["N#{m}"].to_i / 100 rescue 0)
      next if amount == 0

      amount_year += amount
      {
        month: m,
        amount: amount
      }
    }.compact

    lines << { month: 0, amount: amount_year }

    lines.map { |line|
      {
          '_month' => line[:month],

          'fond' => nil,

          'amount' => line[:amount],
          'kvk' => kvk,
          'kekv' => kekv,
          'ktfk' => ktfk,
          'ktfk_aaa' => ktfk_aaa,
      }
    }
  end

end
