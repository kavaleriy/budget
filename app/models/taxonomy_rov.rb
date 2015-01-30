class TaxonomyRov < Taxonomy
  VERSION = 1
  COLUMNS = {
      'kvk' =>{:level => 1, :title=>I18n.t('activerecord.models.taxonomy_rov.department')},
      'ktfk'=>{:level => 2, :title=>I18n.t('activerecord.models.taxonomy_rov.func_code')},
      'kekv' =>{:level => 3, :title=>I18n.t('activerecord.models.taxonomy_rov.economy')},
      # 'krk'=>{:level => 4, :title=>I18n.t('activerecord.models.taxonomy_rov.disposer')},
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
