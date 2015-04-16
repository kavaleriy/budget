class BudgetFileRovFactZvit < BudgetFileRovFact

  protected

  def get_taxonomy owner, columns
    TaxonomyRovFact.get_taxonomy(owner)
  end

  def readline row
    ktfk = row['fcode'].to_s
    ktfk_aaa = ktfk.slice(0, ktfk.length - 3)
    fond = row['cf'].to_s
    kvk = row['kvk'].to_s
    kekv = row['ecode'].to_s


    amount_year = 0
    lines = (1..12).map{|m|
      amount = (row["m#{m}"].to_i rescue 0)
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
          'amount' => line[:amount],
          'fond' => fond,
          'kvk' => kvk,
          'kekv' => kekv,
          'ktfk' => ktfk,
          'ktfk_aaa' => ktfk_aaa,
      }
    }
  end

end
