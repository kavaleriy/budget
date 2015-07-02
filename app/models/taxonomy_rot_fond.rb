class TaxonomyRotFond < Taxonomy

  def columns
      {
        'kkd_a'=>{:level => 1, :title=>I18n.t('mongoid.taxonomy_rot.rank1')},
        'kkd_bb'=>{:level => 2, :title=>I18n.t('mongoid.taxonomy_rot.rank3')},
        'kkd_cc'=>{:level => 3, :title=>I18n.t('mongoid.taxonomy_rot.rank5')},
        'kkd'=>{:level => 4, :title=>I18n.t('mongoid.taxonomy_rot.rank8')},
        # 'fond'=>{:level => 5, :title=> I18n.t('mongoid.taxonomy_rot.fond')},
      }
  end

end
