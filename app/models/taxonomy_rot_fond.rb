class TaxonomyRotFond < Taxonomy
  VERSION = 2
  COLUMNS = {
      'fond'=>{:level => 1, :title=>I18n.t('activerecord.taxonomy_rot_fond.fund')},
      'kkd_a'=>{:level => 2, :title=>I18n.t('activerecord.taxonomy_rot_fond.rank1')},
      'kkd_bb'=>{:level => 3, :title=>I18n.t('activerecord.taxonomy_rot_fond.rank3')},
      'kkd_cc'=>{:level => 4, :title=>I18n.t('activerecord.taxonomy_rot_fond.rank5')},
      'kkd_ddd'=>{:level => 5, :title=>I18n.t('activerecord.taxonomy_rot_fond.rank8')}
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
    return if kkd == ''

    amount1 = row[I18n.t('activerecord.taxonomy_rot_fond.gen_fund')].to_i
    amount2 = row[I18n.t('activerecord.taxonomy_rot_fond.spec_fund')].to_i

    [
        { 'amount' => amount1,
          'fond' => I18n.t('activerecord.taxonomy_rot_fond.gen_fund') },
        { 'amount' => amount2,
          'fond' => I18n.t('activerecord.taxonomy_rot_fond.spec_fund') },
    ].map { |line|
      fond = line['fond']
      amount = line['amount'] / 100

      item = {
          'amount' => amount,
          'fond' => fond,
          '_year' => row['_year'].to_i,
          '_month' => row['_month'].to_i

      }

      [{t: 'kkd_a', key: kkd.slice(0, 1)}, {t: 'kkd_bb', key: kkd.slice(0, 3)}, {t: 'kkd_cc', key: kkd.slice(0, 5)}, {t: 'kkd_ddd', key: kkd.slice(0, 8)}].map { |v|
        item[v[:t]] = v[:key]
      }
    item
    }.reject {|c| c.nil? || c['amount'] == 0 }
  end

  protected

end
