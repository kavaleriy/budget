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

  def self.get_active_or_first(town)

    result = self.get_active_by_town(town).first
    # check for active
    # case 1: return first
    # case 2: return active
    (result.nil?) ? self.owned_by(town).first : result
  end

  # def add_leaf tree, row
  #   kkd_a = row['kkd_a']
  #   kkd_b = row['kkd_b']
  #   kkd_cc = row['kkd_cc']
  #   kkd_dd = row['kkd_dd']
  #   kkd = row['kkd']
  #
  #   tree[kkd_a] = {} if tree[kkd_a].nil?
  #   tree[kkd_a][kkd_b] = {} if tree[kkd_a][kkd_b].nil?
  #   tree[kkd_a][kkd_b][kkd_cc] = {} if tree[kkd_a][kkd_b][kkd_cc].nil?
  #   tree[kkd_a][kkd_b][kkd_cc][kkd_dd] = {} if tree[kkd_a][kkd_b][kkd_cc][kkd_dd].nil?
  #   tree[kkd_a][kkd_b][kkd_cc][kkd_dd][kkd] = [] if tree[kkd_a][kkd_b][kkd_cc][kkd_dd][kkd].nil?
  #
  #   tree[kkd_a][kkd_b][kkd_cc][kkd_dd][kkd] << row
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
