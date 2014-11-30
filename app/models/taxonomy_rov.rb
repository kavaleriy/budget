class TaxonomyRov < Taxonomy
  VERSION = 2
  COLUMNS = {
      'ktfk_aaa'=>{:level => 1, :title=>'Функціональний код, Розряд 1-3'},
      'ktfk'=>{:level => 2, :title=>'Функціональний код'},
      'kekv' =>{:level => 3, :title=>'Економіка'},
      'kvk' =>{:level => 4, :title=>'Відомства'},
      # 'krk'=>{:level => 4, :title=>'Роспорядники'},
  }

  def self.get_taxonomy(name)
    TaxonomyRov.where(:name => name, :columns_id => VERSION).last || TaxonomyRov.create!(
        :name => name,
        :columns_id => VERSION,
        :columns => COLUMNS
    )
  end

  def readline row
    amount = row['SUMM']
    return if amount.nil? || amount == 0

    {
        '_month' => row['MONTH'].to_s,
        'amount' => amount / 100,
        'kvk' => row['KVK'].to_s,
        'kekv' => row['KEKV'].to_s,
        'ktfk_aaa' => row['KTFK'].to_s.slice(0, 3),
        'ktfk' => row['KTFK'].to_s,
        # 'krk' => row['KRK'].to_s,
    }
  end

  protected

  def get_taxonomy_info taxonomy, key
    case taxonomy
      when 'ktfk', 'ktfk_aaa'
        expense_codes[key.ljust(6, '0')] || expense_codes[key.ljust(5, '0')]
      when 'kvk'
        expense_kvk_codes[key]
      when 'kekv'
        expense_ekv_codes[key]
      else
        super
    end
  end

end
