class TaxonomyRov < Taxonomy

  scope :get_rov_by_owner_city, ->(town) { where(:owner => town) }


  def self.get_active_or_first(town)
    # binding.pry
    result = self.get_active_by_town(town).first
    # check for active
    # case 1: return first
    # case 2: return active
    (result.nil?) ? self.owned_by(town).first : result
  end

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
