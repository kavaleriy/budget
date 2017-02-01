module Repairing::LayersHelper
  def years_array year_start
    (year_start..Time.now.year).to_a.reverse
  end
end
