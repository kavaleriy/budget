class ExportBudget::FormPresenter

  def initialize(user,locale)
    @user = user
    @locale = locale
  end

  def taxonomies_rot
    TaxonomyRot.visible_to(@user).to_a
  end

  def taxonomies_rov
    TaxonomyRov.visible_to(@user).to_a
  end

  def calendars
    Calendar.visible_to(@user,@locale).to_a
  end

  def indicates
    Indicate::Taxonomy.visible_to(@user).to_a
  end


end