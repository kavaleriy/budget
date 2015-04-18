class BudgetFileRovFact < BudgetFile

  protected

  def get_taxonomy owner, columns
    TaxonomyRov.get_taxonomy(owner)
  end

  def readline row
    ktfk = row['KFK'].to_s

    ktfk_aaa = ktfk.slice(0, ktfk.length - 3).ljust(3, '0')
    ktfk_aaa = '800' if ktfk_aaa == '810'
    ktfk_aaa = '900' if ktfk_aaa == '910'

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

          'amount' => line[:amount],
          'kvk' => kvk,
          'kekv' => kekv,
          'ktfk' => ktfk,
          'ktfk_aaa' => ktfk_aaa,
      }
    }
  end

  private

  def set_data_type
    self.data_type = :fact if self.data_type.nil?
  end
end
