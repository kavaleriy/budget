class TaxonomyRotFond < TaxonomyRot
  VERSION = 1
  COLUMNS = {
      'fond'=>{:level => 1, :title=>'Фонд'},
      'kkd_a'=>{:level => 2, :title=>'Розряд 1'},
      'kkd_bb'=>{:level => 3, :title=>'Розряд 1-3'},
      'kkd_cc'=>{:level => 4, :title=>'Розряд 1-5'},
      'kkd_ddd'=>{:level => 5, :title=>'Розряд 1-8'}
  }

  def self.get_taxonomy(owner)
    TaxonomyRotFond.where(:owner => owner, :columns_id => VERSION).last || TaxonomyRotFond.create!(
        :owner => owner,
        :columns_id => VERSION,
        :columns => COLUMNS
    )
  end

  def readline row
    kkd = row['kkd'].to_s

    amount1 = row['Загальний фонд'].to_i
    amount2 = row['Спеціальний фонд'].to_i

    [
        { 'amount' => amount1, 'fond' => 'Загальний фонд' },
        { 'amount' => amount2, 'fond' => 'Спеціальний фонд' },
    ].map { |line|
      fond = line['fond']
      amount = line['amount'] / 100

      item = { 'amount' => amount, 'fond' => fond }

      [{t: 'kkd_a', key: kkd.slice(0, 1)}, {t: 'kkd_bb', key: kkd.slice(0, 3)}, {t: 'kkd_cc', key: kkd.slice(0, 5)}, {t: 'kkd_ddd', key: kkd.slice(0, 8)}].map { |v|
        item[v[:t]] = v[:key]
      }
    item
    }.reject {|c| c.nil? || c['amount'] == 0 }
  end

  protected

end
