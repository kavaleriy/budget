class TaxonomyRov < Taxonomy

  # scope :get_rov_by_owner_city, ->(town) { where(:owner => town) }

  def columns

    if is_kvk
      {
          # 'fond'=>{:level => 1, :title=> I18n.t('mongoid.taxonomy_rot.fond')},
          'kvk' =>{:level => 1, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.department')},
          # 'ktfk_aaa'=>{:level => 2, :title=>I18n.t('mongoid.taxonomy_rov.func_code_aaa')},
          'ktfk'=>{:level => 2, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.func_code')},
          'kekv' =>{:level => 3, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.economy')},
          'krk'=>{:level => 4, :title=>I18n.t('mongoid.taxonomy_rov.disposer')},
          'kpk_aa'=>{:level => 5, :title=>I18n.t('mongoid.taxonomy_rov.kpk_aa')},
          # 'kpk_b'=>{:level => 7, :title=>I18n.t('mongoid.taxonomy_rov.kpk_b')},
          'kpk_cccd'=>{:level => 8, :title=>I18n.t('mongoid.taxonomy_rov.kpk_cccd')},
          # 'kpk_d'=>{:level => 9, :title=>I18n.t('mongoid.taxonomy_rov.kpk_d')},
      }
    else
      {
          # 'fond'=>{:level => 1, :title=> I18n.t('mongoid.taxonomy_rot.fond')},
          'ktfk_aaa'=>{:level => 1, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.func_code_aaa')},
          'ktfk'=>{:level => 2, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.func_code')},
          'kekv' =>{:level => 3, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.economy')},
          'krk'=>{:level => 4, :title=>I18n.t('mongoid.taxonomy_rov.disposer')},
          'kvk' =>{:level => 5, :title=>I18n.t('mongoid.taxonomy_rov.department')},
          'kpk_aa'=>{:level => 6, :title=>I18n.t('mongoid.taxonomy_rov.kpk_aa')},
          # 'kpk_b'=>{:level => 7, :title=>I18n.t('mongoid.taxonomy_rov.kpk_b')},
          'kpk_cccd'=>{:level => 8, :title=>I18n.t('mongoid.taxonomy_rov.kpk_cccd')},
          # 'kpk_d'=>{:level => 9, :title=>I18n.t('mongoid.taxonomy_rov.kpk_d')},
      }
    end
  end

  def recipients_column
    :ktfk
  end

end
