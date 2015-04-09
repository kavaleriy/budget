class TaxonomyRov < Taxonomy

  def columns
    {
        'fond'=>{:level => 1, :title=> I18n.t('activerecord.taxonomy_rot.fond')},
        # 'kvk' =>{:level => 2, :title=>I18n.t('activerecord.taxonomy_rov.department')},
        'ktfk_aaa'=>{:level => 2, :title=>I18n.t('activerecord.taxonomy_rov.func_code_aaa')},
        'ktfk'=>{:level => 3, :title=>I18n.t('activerecord.taxonomy_rov.func_code')},
        'kekv' =>{:level => 4, :title=>I18n.t('activerecord.taxonomy_rov.economy')},
        # 'krk'=>{:level => 6, :title=>I18n.t('activerecord.taxonomy_rov.disposer')},
    }
  end

end
