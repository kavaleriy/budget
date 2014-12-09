class TaxonomyRovFond < Taxonomy
  VERSION = 1
  COLUMNS = {
      'fond'=>{:level => 1, :title=>'Фонд'},
      'source'=>{:level => 2, :title=>'Джерело'},
      'owner'=>{:level => 3, :title=>'Розпорядник'},
      'ktfk' =>{:level => 4, :title=>'Функц класифікація'},
  }

  def self.get_taxonomy(owner)
    TaxonomyRovFond.where(:owner => owner, :columns_id => VERSION).last || TaxonomyRovFond.create!(
        :owner => owner,
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
        'amount' => line[:amount] / 100,
        '_year' => line['_year'].to_date.year.to_s,
        '_month' => line['_month'].to_s,
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
