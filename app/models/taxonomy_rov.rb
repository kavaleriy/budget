class TaxonomyRov < Taxonomy

  scope :get_rov_by_owner_city, ->(town) { where(:owner => town) }


  def self.get_active_or_first(town)
    result = self.get_active_by_town(town).first
    # check for active
    # case 1: return first
    # case 2: return active
    (result.nil?) ? self.owned_by(town).first : result
  end

  def self.get_active_for_all_towns
    # this function grouped taxonomies by town
    taxonomies_group_by_town = self.all.group_by{|f| f.owner}.keys

    result = []
    taxonomies_group_by_town.each do |t|
      town = Town.get_town_by_title(t).first
      taxonomy = self.get_active_or_first(t)
      town_blazon = town.img.url unless town.nil? || town.img.nil?
      result << {
          id: taxonomy.id.to_s,
          title: taxonomy.title,
          img: town_blazon
      }
    end

    # and return towns models
    # Town.get_towns_by_titles(taxonomies_group_by_town)

    # and return cases:
    # case 1: active taxonom[y][ies] if exist
    # case 2: first upload taxonomy
    result
  end

  # def self.get_active_taxonomies
  #   active = self.get_towns_with_taxonomies_rov
  # end

  def columns

    if is_kvk
      {
          # 'fond'=>{:level => 1, :title=> I18n.t('mongoid.taxonomy_rot.fond')},
          'kvk' =>{:level => 1, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.department')},
          # 'ktfk_aaa'=>{:level => 2, :title=>I18n.t('mongoid.taxonomy_rov.func_code_aaa')},
          'ktfk'=>{:level => 2, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.func_code')},
          'kekv' =>{:level => 3, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.economy')},
          'krk'=>{:level => 4, :title=>I18n.t('mongoid.taxonomy_rov.disposer')},
      }
    else
      {
          # 'fond'=>{:level => 1, :title=> I18n.t('mongoid.taxonomy_rot.fond')},
          # 'kvk' =>{:level => 2, :title=>I18n.t('mongoid.taxonomy_rov.department')},
          'ktfk_aaa'=>{:level => 1, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.func_code_aaa')},
          'ktfk'=>{:level => 2, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.func_code')},
          'kekv' =>{:level => 3, :draggable => true, :title=>I18n.t('mongoid.taxonomy_rov.economy')},
          'krk'=>{:level => 4, :title=>I18n.t('mongoid.taxonomy_rov.disposer')},
      }
    end
  end

  def recipients_column
    :ktfk
  end

end
