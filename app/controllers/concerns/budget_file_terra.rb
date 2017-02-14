module BudgetFileTerra
  extend ActiveSupport::Concern

  def set_areas
    @areas = Dictionary::TlTerra.areas
    @current_area_id = nil
  end

  def get_terra_title area_id, town_id
    area = get_area area_id
    town = get_town area_id, town_id

    town_id == '001' ? "#{area}" : "#{area}, #{town}"
  end

  def get_area area
    Dictionary::TlTerra.areas[area]
  end

  def get_town area, town_id
    Dictionary::TlTerra.towns(area)[town_id] rescue nil
  end

end
