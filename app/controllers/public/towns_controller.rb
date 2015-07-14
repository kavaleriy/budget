class Public::TownsController < ApplicationController
  layout 'application_public'

  before_action :set_town, only: [:show]

  def index
    @towns = Town.all
  end

  def show
    @budgets = Taxonomy.where(:owner => @town.title)
    @calendars = Calendar.where(:town => @town)
  end

  private

  def set_town
    @town = Town.find(params[:town_id])
  end

end
