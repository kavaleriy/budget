class Widgets::TownProfileController < Widgets::WidgetsController

  def portfolio
    @town = Town.find(params[:town_id])
    town_items = Town.get_town_items_hash(@town)
    render :partial => 'portfolio', :locals => {:town_items => town_items}
  end
end