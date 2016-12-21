class ExportBudget::FormPresenter

  #Get Visualisations by town
  def initialize(town_id,locale)
    @town = town_id
    @locale = locale
  end

  def taxonomies_rot
    TaxonomyRot.by_town_id(@town).to_a
  end
  def taxonomies_rov
    TaxonomyRov.by_town_id(@town).to_a
  end
  def calendars
    Calendar.by_town(@town).get_calendars_by_locale(@locale).to_a
  end
  def indicates
    Indicate::Taxonomy.get_indicate_by_town(@town).to_a
  end

end