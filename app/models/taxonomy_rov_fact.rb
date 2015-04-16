class TaxonomyRovFact < Taxonomy

  def columns
    if is_kvk
      {
          'kvk' =>{:level => 1, :title=>I18n.t('activerecord.taxonomy_rov.department')},
          'ktfk'=>{:level => 2, :title=>I18n.t('activerecord.taxonomy_rov.func_code')},
          'kekv' =>{:level => 3, :title=>I18n.t('activerecord.taxonomy_rov.economy')},
      }
    else
      {
          'ktfk_aaa'=>{:level => 1, :title=>I18n.t('activerecord.taxonomy_rov.func_code_aaa')},
          'ktfk'=>{:level => 2, :title=>I18n.t('activerecord.taxonomy_rov.func_code')},
          'kekv' =>{:level => 3, :title=>I18n.t('activerecord.taxonomy_rov.economy')},
      }
    end
  end

end
