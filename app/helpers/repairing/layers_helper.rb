module Repairing::LayersHelper
  def years_from(year_start)
    (year_start..Time.now.year).to_a.reverse
  end

  def select_years(count)
    current_year = Time.now.year
    year_from = current_year - count
    (year_from..current_year).to_a.reverse
  end

  # show town_select for admin
  def type_for_user_role
    current_user.admin? ? :text : :hidden
  end
end
