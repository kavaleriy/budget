class TaxonomyRot < Taxonomy

  def columns
      {
        'kkd_a'=>{:level => 1, :title=>I18n.t('mongoid.taxonomy_rot.rankA')},
        'kkd_b'=>{:level => 2, :title=>I18n.t('mongoid.taxonomy_rot.rankB')},
        'kkd_cc'=>{:level => 3, :title=>I18n.t('mongoid.taxonomy_rot.rankCC')},
        'kkd_dd'=>{:level => 4, :title=>I18n.t('mongoid.taxonomy_rot.rankDD')},
        'kkd_ee'=>{:level => 5, :title=>I18n.t('mongoid.taxonomy_rot.rankEE')},
        # 'fond'=>{:level => 5, :title=> I18n.t('mongoid.taxonomy_rot.fond')},
      }
  end

  def recipients_column
    :kkd_ee
  end

  # def add_leaf tree, row
  #   kkd_a = row['kkd_a']
  #   kkd_b = row['kkd_b']
  #   kkd_cc = row['kkd_cc']
  #   kkd_dd = row['kkd_dd']
  #   kkd_ee = row['kkd_ee']
  #
  #   tree[kkd_a] = {} if tree[kkd_a].nil?
  #   tree[kkd_a][kkd_b] = {} if tree[kkd_a][kkd_b].nil?
  #   tree[kkd_a][kkd_b][kkd_cc] = {} if tree[kkd_a][kkd_b][kkd_cc].nil?
  #   tree[kkd_a][kkd_b][kkd_cc][kkd_dd] = {} if tree[kkd_a][kkd_b][kkd_cc][kkd_dd].nil?
  #   tree[kkd_a][kkd_b][kkd_cc][kkd_dd][kkd_ee] = [] if tree[kkd_a][kkd_b][kkd_cc][kkd_dd][kkd_ee].nil?
  #
  #   tree[kkd_a][kkd_b][kkd_cc][kkd_dd][kkd_ee] << row
  # end
  #
  # def extract_rows tree
  #   rows = []
  #   tree.keys.each{|a|
  #     tree[a].keys.each{|b|
  #       tree[a][b].keys.each{|cc|
  #         tree[a][b][cc].keys.each{|dd|
  #           tree[a][b][cc][dd].keys.each{|ee|
  #             rows << tree[a][b][cc][dd][ee]
  #           }  if dd != '00' or tree[a][b][cc].count == 1
  #         } if cc != '00' or tree[a][b].count == 1
  #       } if b != '0' or tree[a].count == 1
  #     } if a != '0' or tree.count == 1
  #   }
  #
  #   rows
  # end

end
