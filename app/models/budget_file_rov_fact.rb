class BudgetFileRovFact < BudgetFile

  protected

  def get_taxonomy owner, columns
    TaxonomyRovFact.get_taxonomy(owner)
  end

  def readline row
    ktfk = row['ktfk'].to_s

    1..12.map { |month|

      amount = row["N#{month}"]
      next if line[:amount].nil?

    }.reject {|c| c.nil? || c['amount'] == 0 }


              'fond' => line[:fond],

              # 'kvk' => "#{row['kvk'].to_s}:#{row['krk'].to_s}",
              'kekv' => row['kekv'].to_s || '-',
              'ktfk' => ktfk,
              'ktfk_aaa' => ktfk.slice(0, ktfk.length - 3),
              # 'krk' => row['KRK'].to_s,
          }

      %w(_year _month).each{ |key|
        item[key] = row[key].to_i unless row[key].nil?
      }

      item
    }.reject {|c| c.nil? || c['amount'] == 0 }
  end

end

