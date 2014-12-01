class TaxonomyRovFond < TaxonomyRov
  VERSION = 1
  COLUMNS = {
      'fond'=>{:level => 1, :title=>'Фонд'},
      'source'=>{:level => 2, :title=>'Джерело'},
      'owner'=>{:level => 3, :title=>'Розпорядник'},
      'ktfk' =>{:level => 4, :title=>'Функц класифікація'},
  }

  def self.get_taxonomy(name)
    TaxonomyRovFond.where(:name => name, :columns_id => VERSION).last || TaxonomyRovFond.create!(
        :name => name,
        :columns_id => VERSION,
        :columns => COLUMNS
    )
  end

  def readline row
    amount1 = row['Загальний фонд'].to_i
    amount2 = row['Спеціальний фонд'].to_i

    [
      { :amount => amount1, :fond => 'Загальний фонд' },
      { :amount => amount2, :fond => 'Спеціальний фонд' },
    ].map { |line|
    {
        'amount' => line[:amount],
        'fond' => line[:fond],
        'source' => row['Джерело'].to_s,
        'owner' => row['Розпорядник'].to_s.split('.')[0],
        'ktfk' => row['Функц класифікація'].to_s.split('.')[0],
      }
    }.reject {|c| c.nil? || c['amount'] == 0 }
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
