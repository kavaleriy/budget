class TaxonomyRov < Taxonomy

  def columns

    if is_kvk
      {
          'kvk' =>{:level => 1, :title=>I18n.t('activerecord.taxonomy_rov.department')},
          # 'krk'=>{:level => 2, :title=>I18n.t('activerecord.taxonomy_rov.disposer')},
          # 'ktfk_aaa'=>{:level => 2, :title=>I18n.t('activerecord.taxonomy_rov.func_code_aaa')},
          'ktfk'=>{:level => 2, :title=>I18n.t('activerecord.taxonomy_rov.func_code')},
          'kekv' =>{:level => 3, :title=>I18n.t('activerecord.taxonomy_rov.economy')},
      }
    else
      {
          # 'kvk' =>{:level => 2, :title=>I18n.t('activerecord.taxonomy_rov.department')},
          'ktfk_aaa'=>{:level => 1, :title=>I18n.t('activerecord.taxonomy_rov.func_code_aaa')},
          # 'krk'=>{:level => 5, :title=>I18n.t('activerecord.taxonomy_rov.disposer')},
          'ktfk'=>{:level => 2, :title=>I18n.t('activerecord.taxonomy_rov.func_code')},
          'kekv' =>{:level => 3, :title=>I18n.t('activerecord.taxonomy_rov.economy')},
      }
    end

  end

end
