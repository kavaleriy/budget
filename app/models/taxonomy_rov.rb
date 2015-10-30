class TaxonomyRov < Taxonomy

  def columns

    if is_kvk
      {
          # 'fond'=>{:level => 1, :title=> I18n.t('mongoid.taxonomy_rot.fond')},
          'kvk' =>{:level => 1, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.department')},
          # 'krk'=>{:level => 2, :title=>I18n.t('mongoid.taxonomy_rov.disposer')},
          # 'ktfk_aaa'=>{:level => 2, :title=>I18n.t('mongoid.taxonomy_rov.func_code_aaa')},
          'ktfk'=>{:level => 2, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.func_code')},
          'kekv' =>{:level => 3, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.economy')},
      }
    else
      {
          # 'fond'=>{:level => 1, :title=> I18n.t('mongoid.taxonomy_rot.fond')},
          # 'kvk' =>{:level => 2, :title=>I18n.t('mongoid.taxonomy_rov.department')},
          'ktfk_aaa'=>{:level => 2, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.func_code_aaa')},
          # 'krk'=>{:level => 5, :title=>I18n.t('mongoid.taxonomy_rov.disposer')},
          'ktfk'=>{:level => 3, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.func_code')},
          'kekv' =>{:level => 4, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.economy')},
      }
    end
  end

  def recipients_column
    :ktfk
  end

end
