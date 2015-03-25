class TaxonomyRov < Taxonomy
  VERSION = 4
  COLUMNS = {
      'fond'=>{:level => 1, :title=> I18n.t('activerecord.taxonomy_rot.fond')},
      'kvk' =>{:level => 2, :title=>I18n.t('activerecord.taxonomy_rov.department')},
      'ktfk'=>{:level => 3, :title=>I18n.t('activerecord.taxonomy_rov.func_code')},
      'kekv' =>{:level => 4, :title=>I18n.t('activerecord.taxonomy_rov.economy')},
      # 'krk'=>{:level => 4, :title=>I18n.t('activerecord.taxonomy_rov.disposer')},
  }

  def self.get_taxonomy(owner)
    TaxonomyRov.where(:owner => owner, :columns_id => VERSION).last || TaxonomyRov.create!(
        :owner => owner,
        :columns_id => VERSION,
        :columns => COLUMNS
    )
  end

  def readline row
    amount = row['SUMM'].to_i
    return if amount.nil? || amount == 0

    {
        '_year' => row['DATA'].to_date.year.to_s,
        '_month' => row['MONTH'].to_s.split('.')[0],
        'amount' => amount / 100,
        'fond' => row['KKFN'].to_s,
        'kvk' => "#{row['KVK'].to_s}:#{row['KRK'].to_s}",
        'kekv' => row['KEKV'].to_s,
        'ktfk_aaa' => row['KTFK'].to_s.slice(0, 3),
        'ktfk' => row['KTFK'].to_s,
        # 'krk' => row['KRK'].to_s,
    }
  end

  protected

end
