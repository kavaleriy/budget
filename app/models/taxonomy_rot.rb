class TaxonomyRot < Taxonomy

  # scope :get_rot_by_owner_city, ->(town) { where(:owner => town) }

  def columns
      {
        'kkd_a'=>{:level => 1, :title=>I18n.t('mongoid.taxonomy_rot.rankA')},
        'kkd_b'=>{:level => 2, :title=>I18n.t('mongoid.taxonomy_rot.rankB')},
        'kkd_cc'=>{:level => 3, :title=>I18n.t('mongoid.taxonomy_rot.rankCC')},
        'kkd_dd'=>{:level => 4, :title=>I18n.t('mongoid.taxonomy_rot.rankDD')},
        'kkd'=>{:level => 5, :title=>I18n.t('mongoid.taxonomy_rot.rank')},
        # 'fond'=>{:level => 5, :title=> I18n.t('mongoid.taxonomy_rot.fond')},
      }
  end

  def recipients_column
    :kkd
  end


end
