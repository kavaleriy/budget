class TaxonomyRovFact < Taxonomy

  def columns
    {
        # 'kvk' =>{:level => 1, :title=>I18n.t('activerecord.taxonomy_rov.department')},
        'ktfk_aaa'=>{:level => 1, :title=>I18n.t('activerecord.taxonomy_rov.func_code_aaa')},
        'ktfk'=>{:level => 2, :title=>I18n.t('activerecord.taxonomy_rov.func_code')},
        'kekv' =>{:level => 3, :title=>I18n.t('activerecord.taxonomy_rov.economy')},
        # 'krk'=>{:level => 4, :title=>I18n.t('activerecord.taxonomy_rov.disposer')},
        # 'fond'=>{:level => 4, :title=> I18n.t('activerecord.taxonomy_rot.fond')},
    }
  end

end
