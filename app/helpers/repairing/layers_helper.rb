module Repairing::LayersHelper
  def years_array year_start
    (year_start..Time.now.year).to_a.reverse
  end

  # show town_select for admin
  def type_for_user_role
    current_user.admin? ? :text : :hidden
  end
end
