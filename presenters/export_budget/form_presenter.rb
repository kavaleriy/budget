class ExportBudget::FormPresenter

  # def initialize(user_id,locale)
  #   @user = User.find(user_id)
  #   @locale = locale
  # end
  #
  # def taxonomies_rot
  #   TaxonomyRot.visible_to(@user).to_a
  # end
  #
  # def taxonomies_rov
  #   TaxonomyRov.visible_to(@user).to_a
  # end
  #
  # def calendars
  #   Calendar.visible_to(@user,@locale).to_a
  # end
  #
  # def indicates
  #   Indicate::Taxonomy.visible_to(@user).to_a
  # end


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
    Calendar.get_calendar_by_town(@town).to_a #.get_calendars_by_locale(@locale).to_a
  end
  def indicates
    Indicate::Taxonomy.get_indicate_by_town(@town).to_a
  end

end